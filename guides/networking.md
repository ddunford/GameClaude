# Guide — Networking craft (multiplayer under latency)

> Read before designing or building anything a second player must see, feel, or shoot at. The core idea: **authority is settled — the server owns state, the client is never trusted — but a server-authoritative game that waits for the round-trip before it moves feels broken. This guide is the craft of hiding latency without surrendering authority: predict locally, reconcile to the server, interpolate everyone else, and compensate for lag at the moment of the shot.**

Authority and *whether* to replicate are settled law — the studio doctrine (11) and `agents/network-engineer` own that. This guide owns the layer above: **how it feels at 80 ms.** The engine facts it stands on — Iris, spatial filtering, the 128-connection cap, ASC-on-PlayerState, push-model-is-PIE-only — live in `guides/unreal-engine.md §3` and are **linked, never restated**; that guide is the source of truth for anything the engine actually does.

## The two failures this prevents
1. **Correct but dead.** A perfectly authoritative build where every input waits a full round-trip before anything happens on screen — movement rubber-bands, shots feel like they miss, the world lurches on every server update. Authority was never the hard part; responsiveness under latency is.
2. **Responsive but exploitable.** The opposite over-correction: the client is trusted to make it feel good — it reports its own position, its own hits, its own currency — and the game plays great until the first cheater. Prediction is a *rendering* trick on top of an authoritative server, never a transfer of authority to the client.

## PRINCIPLES
The craft rules that hold across every networked system. They sit *on top of* the never-trust-client authority rules, never in place of them.
- **The server owns truth; the client owns the illusion of immediacy.** Prediction, interpolation, and smoothing all run on the client to hide latency. None of them decide anything. Every one is reconciled to, or validated by, the server.
- **Predict the local player; interpolate everyone else.** You have the local player's inputs the instant they happen, so simulate them immediately and correct later. You do *not* have remote players' inputs — you have their past positions, so render them smoothly in the past. These are different problems with different solutions; do not confuse them.
- **Render remote entities in the past, deliberately.** A fixed interpolation delay buys you smooth motion between two *real* server snapshots. Guessing the future (extrapolation) to shave that delay trades jitter for rubber-banding — usually a bad trade.
- **Event-driven over tick, always.** State that changes on an event replicates on that event (push-model / RepNotify), not on a poll. A property re-sent every frame because "it might have changed" is the single most common source of wasted bandwidth. Flag tick-based replication in every design.
- **Reliable is a scarce, ordered channel — treat it that way.** Reliable RPCs are for discrete, must-arrive, must-order events. Anything frequent, anything bindable to a button-mash, anything that is really *state* — is not a reliable RPC.
- **RPCs are events, not state.** A late-joiner, a relevancy re-entry, or a dropped-then-recovered connection sees replicated *state*; it does **not** replay the RPCs it missed. If a thing must be true for everyone who ever sees the actor, it is a replicated property, not a multicast.
- **Every hidden-latency trick has a bandwidth and a fairness cost — state it.** Prediction costs CPU (replay) and correction bandwidth; interpolation costs delay; lag compensation costs the victim fairness ("shot behind cover"); a higher send rate costs kbit/s linearly. There is no free responsiveness. Name the cost in the design.
- **Measure bandwidth per connection, against a budget.** "It runs fine in PIE with two clients on localhost" is not a bandwidth result. A budget-per-connection exists before the system ships, and it is measured, not assumed.

## The latency problem, and the three-part answer
A ~50 ms one-way latency (a ~100 ms round-trip) means a naive authoritative client waits a tenth of a second between input and any visible result — unplayable for anything with movement or aim ([Gambetta, Part I]). The standard answer, unchanged since Quake/Source and still how Unreal's `CharacterMovementComponent` (CMC) works, is three cooperating techniques:

1. **Client-side prediction** — the local player acts *now*, locally, without waiting.
2. **Server reconciliation** — the server's authoritative correction is folded back in without losing the inputs the player has issued since.
3. **Entity interpolation** — every *other* player is rendered smoothly, slightly in the past, between real server updates.

Lag compensation (server rewind for hits) is the fourth, layered on top when the game has aimed, instant-hit actions. Get these four right and an 80 ms game feels local; get any one wrong and it feels like one of the failure modes below.

## 1 — Client-side prediction & server reconciliation
**The mechanism** ([Gambetta, Part II]):
- Every input the client sends carries a **monotonic sequence number**, and the client keeps a list of inputs it has sent but the server has not yet acknowledged.
- The client applies each input to its **local** state the instant it is issued — the player sees the result immediately.
- The server processes inputs authoritatively and, in its state update, returns **the sequence number of the last input it processed**.
- On receiving that update the client (a) snaps the predicted actor to the authoritative state, (b) **discards every input at or below the acknowledged sequence number**, and (c) **re-applies ("replays") the still-pending inputs** on top of the authoritative state. Because those inputs were already reflected in the last predicted frame, the replay is invisible when prediction was correct — and self-correcting when it was not.

Worked example ([Gambetta, Part II]): the player taps right twice at 250 ms latency. At t=0 the client predicts x=12. At t=250 the server acknowledges input #1 (x=11) but hasn't seen #2; the client accepts x=11 and replays #2 back to x=12 — no visible snap. At t=350 #2 is acknowledged, nothing pending.

**Where Unreal already does this — link, don't rebuild.** CMC is a production client-prediction + server-reconciliation + replay system for locomotion: the client predicts movement locally, batches moves as `FSavedMove_Character`, sends them via the `ServerMovePacked` RPC, and the server replies with an accept (`ClientAckGoodMove`) or a correction (`ClientAdjustPosition`) that triggers a replay of the still-unacknowledged saved moves (the replay loop at `CharacterMovementComponent.cpp:8664-8691`) — the exact loop above. **Do not hand-roll movement prediction; use and configure CMC.** For **abilities**, GAS carries its own prediction path (prediction keys / scoped prediction windows) so a client can locally start an ability and have the server confirm or roll it back — with two hard limits to design around: GAS prediction is **single-frame / single-callstack only** (`GameplayPrediction.h:76-78`), and **GameplayEffect removal and periodic effects are NOT predicted** (`GameplayPrediction.h:48-49`). The *pattern* is settled; the fuller engine detail is `guides/unreal-engine.md §3`'s to own. `[SRC: CharacterMovementComponent.cpp:8664-8691; GameplayPrediction.h:48-49,76-78]`

**What you still design:** what is predicted at all (locomotion and cosmetic ability feedback — yes; currency, inventory grants, damage numbers, authoritative hit results — **no**, these wait for the server because a mispredicted gold balance is worse than a delayed one), how a misprediction is *smoothed* rather than snapped (see §2), and how the server validates each predicted input as hostile (see §5 / `harden-endpoint`).

## 2 — Entity interpolation & smoothing (remote proxies)
The local player is predicted. **Every remote actor is interpolated**, because the client has their past positions but not their inputs.

- The client buffers the position snapshots it receives and renders each remote entity at **`renderTime = now − interpolationDelay`**, interpolating between the two buffered snapshots that straddle that time. It is always showing *real* movement data, just shown "late" ([Gambetta, Part III]).
- **The interpolation delay is a function of the update rate**, not a free parameter. At a 10 Hz server (100 ms between updates) you render ~100 ms in the past ([Gambetta, Part III]). The buffer must be large enough to absorb jitter and a lost packet — Gaffer is commonly cited as sizing it at roughly **3× the send interval** (≈300 ms at 10 pps), with a 350 ms buffer surviving 5% packet loss ([Gaffer, Snapshot Interpolation]) `[verify — web pass]`.
- **The delay/latency trade is real and it is bought with send rate, not cleverness.** Gaffer is commonly cited for a 60 pps stream needing only an ~85 ms buffer where 30 pps needs ~150 ms ([Gaffer, Snapshot Interpolation]) `[verify — web pass]`. Raising the send rate is the honest way to reduce interpolation delay; extrapolation is the tempting way (see below).
- **Smoothing** is separate from interpolation: when the *local predicted* player is corrected (§1), snapping the mesh is jarring — blend the visual (mesh/camera) toward the corrected capsule over a few frames rather than teleporting it. Unreal exposes exactly this on CMC (`NetworkSmoothing`); prefer it to a raw snap.

**Extrapolation (dead reckoning) and its risk.** Instead of rendering in the past you can *predict* a remote entity forward from its last known velocity/acceleration. It works for tightly constrained motion (a car) and **fails hard for anything that can change direction instantly** — the predicted position goes "extremely wrong" the moment the player does something unexpected, producing a correction snap the player reads as rubber-banding ([Gambetta, Part III]; [Gaffer, Snapshot Interpolation] — "extrapolation doesn't work very well for rigid bodies because their motion is non-linear and unpredictable"). Default to interpolation-in-the-past; reach for extrapolation only to paper over a *single* dropped packet, and cap how far it will run.

## 3 — Lag compensation (server rewind) & the fairness trade-off
For aimed, instant-hit actions (a hitscan shot), a shooter is aiming at where interpolation drew the target — i.e. **in the past**. If the server checks the hit against the target's *current* authoritative position, every well-aimed shot at a moving target misses. Lag compensation fixes this by **rewinding**:

- The server keeps a short history of every relevant actor's recent positions. It can "reconstruct the world exactly as it looked to any client at any point in time" ([Gambetta, Part IV]).
- When it processes a shot, it rewinds the other actors to the instant the shooter actually saw them — the shooter's own render time, i.e. `now − (shooter latency + shooter interpolation delay)` — validates the hit against *that* reconstructed state, then applies damage authoritatively.
- **The trade-off is fairness, and it is unavoidable.** The shooter gets the shot they earned; the victim can be hit "a fraction of a second later, when they thought they were safe" behind cover ([Gambetta, Part IV]). This is "favor the shooter," and it is the industry-standard choice for fast games because missing shots you clearly landed feels worse to more players than occasionally dying just behind cover.
- **Bound the rewind.** Cap how far back the server will rewind (Source is commonly cited as clamping to ~1 s of history `[verify — web pass]`) so a high-latency or spoofed-timestamp client cannot ask the server to validate a shot against an arbitrarily old world — that clamp is a **security check**, not just a memory bound. The timestamp the client sends is hostile input like any other (`harden-endpoint`).

**Cost to state in the design:** a position history ring buffer per relevant actor (memory), the rewind/re-check CPU at fire time, and the named fairness cost to the victim. For ElseCity, lag compensation is per-district: it belongs in unsafe combat districts, not in the safe Neon Hub where there is nothing to hit-validate.

## 4 — Bandwidth & budgets
Responsiveness is bought with packets, so bandwidth is a first-class design constraint, not an afterthought.

**The levers, cheapest-win first:**
- **Relevancy** — don't send an actor to a connection that can't perceive it. Under Iris every `AActor` is spatially filtered by default; distance culling is plain per-object cull distance. The mechanism and its traps (always-relevant exemptions, `MaxNetCullDistance`) are `guides/unreal-engine.md §3`'s — **link, don't duplicate**. This is the biggest lever ElseCity has: a zone-sharded city means most actors are irrelevant to most connections most of the time.
- **Dormancy** — an actor that isn't changing shouldn't even be *considered* for replication. Unreal calls this "one of the most significant optimizations you can make" ([UE Networking Overview]). Set actors dormant when idle; flush dormancy on change.
- **Update frequency & priority** — replicate important, fast-moving actors often and distant/cosmetic ones rarely; the priority system decides who gets the bytes when bandwidth is tight ([UE Networking Overview]). Tune `NetUpdateFrequency` per class; expose it to data.
- **Delta compression** — send only what changed since the last acknowledged state, not the full snapshot. This is done by the core replication machinery *with or without* push model; **push model is change-*detection*, not the on-wire delta** — mark-dirty decides which properties are even checked each cycle, not what goes over the wire (mechanism + citations in `guides/unreal-engine.md §3`). Push model is also **PIE-only on this engine** — same section.
- **Quantization** — don't spend 32-bit floats on things the eye can't resolve. Quantize positions/rotations to the precision the game actually needs (Gaffer uses bounded, quantized position + slerp'd quaternions and gets smooth motion at 10 pps; [Gaffer, Snapshot Interpolation]).

**Ballpark numbers to reason with (not to ship without measuring):**
- Gaffer's reference: 900 objects at 10 pps ≈ **25 KB/snapshot ≈ 2 Mbit/s** *before* delta/quantization — which is why relevancy and delta compression are not optional at scale ([Gaffer, Snapshot Interpolation]).
- A send rate of **10–30 Hz** for a busy actor is typical; **60 Hz** buys a shorter interpolation buffer at ~2× the bytes of 30 Hz.
- Unreal caps **per-connection** bandwidth by default at **~10 KB/s** (`MaxInternetClientRate=10000` bytes/s for internet play — mechanism and citations in `guides/unreal-engine.md §3`); the per-actor budget is whatever's left after that's divided across relevant actors by priority. Design to the per-connection cap × 128 connections (the hard Iris cap — `guides/unreal-engine.md §3`), not to what localhost PIE tolerates.

**How to measure — and the honest caveat.** Use `Stat Net`, `Net PktLag`/`PktLoss`, and the CSV network profiler to read actual per-connection and per-actor bytes. **But:** on this project both PIE-as-client and `-server` run `WITH_EDITOR=1`, which leaves cooked-server bandwidth paths untested — so these routes are valid for *authority/replication/relevancy correctness* and **invalid for real performance/bandwidth numbers** until the source build. That constraint is `guides/unreal-engine.md §1`'s; honour it — never quote a PIE bandwidth figure as a shipping number.

## 5 — RPC reliability & ordering
RPCs are the event channel; getting their reliability class wrong is a top source of both bugs and dropped packets.

- **Reliable** — guaranteed delivery, ordered relative to other reliable RPCs on the same actor. Use for discrete, must-happen events: "door opened," "ability granted," "trade confirmed." The reliable queue is **finite** and **overflowing it disconnects the client**.
- **Unreliable** — may be dropped, cheap, fire-and-forget. Use for frequent, self-correcting, or cosmetic calls: anything called per-tick, transient effects, non-authoritative feedback ([UE Networking Overview]: "Make RPCs unreliable if they are called especially often, such as inside an actor tick function").
- **Never bind a reliable RPC to raw player input.** Players mash buttons; a reliable RPC per press "can overflow the reliable RPC queue" ([UE Networking Overview]) and drop the connection — a trivial self-DoS and a griefing vector. Rate-limit and/or make it unreliable, and validate the rate server-side (`harden-endpoint`).
- **RPCs are not state, and they do not backfill.** A multicast fires once, to whoever is relevant at that instant. A client that was out of relevancy, joined late, or recovered from a drop **never receives it**. If the effect must persist for anyone who later sees the actor, replicate a **property** (with a RepNotify to react), not an RPC. Prefer RepNotify to RPC wherever the thing is really state ([UE Networking Overview]).
- **Ordering is per-actor, and only within a reliability class.** Reliable RPCs on the same actor arrive in order; reliable vs unreliable are not ordered against each other; RPCs on *different* actors are not ordered against each other. Never design a handshake that depends on a reliable and an unreliable call arriving in a particular order.

## 6 — Authority & never-trust-client (the lens over everything above)
This is the studio's first law (doctrine 11) and `agents/network-engineer`'s core — folded in here because **every technique above is a place authority can leak.** The rule: prediction, interpolation, and lag comp change what the client *renders*, never what the server *believes*.

- The client sends **inputs and requests**, never results. "I pressed forward," not "I am at (x,y)." "I fired at this timestamp," not "I hit player 7." The server predicts nothing on the client's word — it validates.
- **Every value the client supplies is hostile:** input sequence numbers (replay/skip), fire timestamps (rewind abuse — clamp it, §3), ability activations (`CanActivateAbility` on the server is truth), RPC call rate (overflow/DoS, §5), any position or currency or inventory delta (reject outright; the server computes these).
- **Each server-side check names the exploit it prevents** — that is the `harden-endpoint` discipline, and it is not optional. A predicted client is a *convenience*; the server-side validation of that prediction is the *security boundary*.
- Hand **every** client-reachable endpoint to `agents/security-reviewer` and **every** networked change to `agents/qa-network` (server + 2 clients + the negative/exploit test). One client cannot verify replication; the second client is what catches owner-relevancy mistakes — see `guides/unreal-engine.md §3`.

## QUALITY BAR
A networked system is ready to recommend when all of these hold — verified across a dedicated server + 2 clients by `qa-network`, never self-signed:
- **Responsive.** The local player's own actions have no perceptible input-to-screen delay at the target latency (predicted locally), and corrections are smoothed, not snapped.
- **Smooth for others.** Remote actors move fluidly between server updates with no jitter and no rubber-band; interpolation delay is sized to the send rate and survives a dropped packet.
- **Authoritative.** The server owns and validates position, currency, inventory, ability activation, and hit results. No client-supplied result is trusted anywhere; each check names its exploit.
- **Fair, knowingly.** If lag compensation is used, the rewind is bounded, the fairness cost is stated, and it is scoped to where it belongs (combat districts, not the safe hub).
- **Event-driven.** State replicates on change (push-model/RepNotify), not on a poll; no property is re-sent every tick "just in case." Tick-based replication is justified or removed.
- **Reliability-correct.** Reliable RPCs are discrete and infrequent and cannot be input-mashed into an overflow; frequent/cosmetic calls are unreliable; persistent effects are replicated state, not one-shot RPCs.
- **Within budget, measured.** A per-connection bandwidth budget exists and is measured with the network profiler — with the `WITH_EDITOR=1` caveat honoured (correctness yes, shipping perf numbers no).
- **Verified across three parties + negative test.** Server and both clients agree; the exploit/negative test passes; state survives a relevancy exit-and-return and a late join.

## COMMON FAILURE MODES
- **No prediction → laggy feel.** Every input waits a round-trip; movement and abilities feel like they're dragging through mud. → predict the local player (use CMC/GAS prediction); reconcile, don't wait.
- **No interpolation → jittery proxies.** Remote players teleport from one server update to the next. → render remote entities in the past, interpolating between buffered snapshots sized to the send rate.
- **Extrapolation rubber-banding.** Guessing remote motion forward to cut delay, then snapping when the guess is wrong. → default to interpolation-in-the-past; cap extrapolation to a single dropped packet, never as the baseline.
- **Snapping instead of smoothing corrections.** A mispredicted local player visibly teleports on every server correction. → blend the visual toward the corrected state over frames (network smoothing), don't snap the mesh.
- **Trusting client state.** Client reports its own position/currency/hits and the server takes its word. → server computes and validates everything; client sends inputs/requests only; each check names its exploit (`harden-endpoint`, `security-reviewer`).
- **Reliable-RPC spam / overflow.** A reliable RPC bound to player input mashes the reliable queue to overflow and disconnects the client — a self-DoS and a griefing vector. → unreliable for frequent calls, rate-limited and server-validated for the rest.
- **RPC used where state was needed.** A one-shot multicast that a late-joiner or relevancy re-entrant never sees, so their world is permanently wrong. → replicate a property + RepNotify for anything that must persist.
- **No bandwidth budget.** "Fine on localhost," then it saturates real connections at 30 players. → budget per connection up front; measure with the profiler; lean on relevancy, dormancy, delta, and quantization.
- **Replicating what should be event-driven.** A property re-sent every tick because it *might* change, burning bandwidth on unchanged data. → push-model/RepNotify on change; flag every tick-based replication in review.
- **Quoting PIE bandwidth as a shipping number.** Reading bytes under `WITH_EDITOR=1` and treating them as production. → correctness from PIE/`-server`; real perf/bandwidth waits for the source build (`guides/unreal-engine.md §1`).

## CHECKLIST
**Design (before building):**
- [ ] Authority named for every piece of state (position, currency, inventory, ability, transition) — server owns all of it.
- [ ] Decided what is predicted (locomotion, cosmetic ability feedback) vs what waits for the server (currency, grants, authoritative hits).
- [ ] Remote actors are interpolated; interpolation delay chosen from the send rate; buffer sized to survive a dropped packet.
- [ ] Lag compensation decided per-district (used in combat, bounded rewind, fairness cost stated) or consciously omitted.
- [ ] Every replicated property is event-driven (push-model/RepNotify); no tick-based replication without a written justification.
- [ ] Every RPC classified reliable/unreliable; no reliable RPC on raw input; persistent effects are state, not RPCs.
- [ ] Per-connection bandwidth budget written down; relevancy/dormancy/priority/quantization plan named.
- [ ] Engine claims (CMC/GAS prediction internals, Iris behaviour, defaults) verified via `agents/engine-verifier` against `guides/unreal-engine.md §3` — not asserted from memory.

**Build:**
- [ ] Local prediction reconciles by replaying unacknowledged inputs; corrections are smoothed, not snapped.
- [ ] Remote-proxy interpolation implemented; no extrapolation as the baseline.
- [ ] Every client-supplied value (sequence numbers, timestamps, activations, deltas, RPC rate) treated as hostile and validated server-side; each check names the exploit (`harden-endpoint`).
- [ ] Bandwidth measured with the network profiler against the budget — `WITH_EDITOR=1` caveat honoured.

**Before recommending done:**
- [ ] Quality bar met.
- [ ] Handed to `agents/security-reviewer` (every client-reachable endpoint) and `agents/qa-network` (server + 2 clients + negative test) — not self-signed.
- [ ] Verified from all three parties; state survives relevancy exit/return and a late join; the exploit test fails to exploit.

## Sources
Craft grounded in the standard multiplayer-networking literature:
- **Gabriel Gambetta**, *Fast-Paced Multiplayer* — [Part I: Client-Server Game Architecture](https://www.gabrielgambetta.com/client-server-game-architecture.html), [Part II: Client-Side Prediction and Server Reconciliation](https://www.gabrielgambetta.com/client-side-prediction-server-reconciliation.html), [Part III: Entity Interpolation](https://www.gabrielgambetta.com/entity-interpolation.html), [Part IV: Lag Compensation](https://www.gabrielgambetta.com/lag-compensation.html).
- **Glenn Fiedler (Gaffer On Games)** — [Snapshot Interpolation](https://gafferongames.com/post/snapshot_interpolation/), and the *Networked Physics* / *State Synchronization* series (`gafferongames.com`).
- **Valve** — [Source Multiplayer Networking](https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking) and [Latency Compensating Methods in Client/Server In-game Protocol Design](https://developer.valvesoftware.com/wiki/Latency_Compensating_Methods_in_Client/Server_In-game_Protocol_Design_and_Optimization) — the canonical prediction + interpolation + server-rewind model; specific Source defaults marked `[verify — web pass]` where not re-confirmed here.
- **Timothy Ford (Blizzard), GDC 2017** — *Overwatch Gameplay Architecture and Netcode* — high-frequency command frames, prediction, and "favor the shooter" lag compensation in a shipping title.
- **Epic Games** — [Networking Overview for Unreal Engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/networking-overview-for-unreal-engine); *Networked Movement in the Character Movement Component*. Engine-specific facts (Iris, spatial filtering, connection cap, push-model, defaults) are owned by `guides/unreal-engine.md §3`.
