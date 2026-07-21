# Guide — Game Feel (responsiveness & juice)

> Read before building or tuning any player-facing mechanic — movement, abilities, interactions, camera. The core idea: **feel is not decoration you add at the end; it is the moment-to-moment quality of control, and it is built to a measurable bar and proven by being felt — never asserted.** "It feels good" is a hypothesis until someone walks it and a fresh reviewer agrees.

## The two failures this prevents
1. **Asserted feel.** A mechanic shipped as "feels right" with no definition of *right*, no numbers, and no spike. Feel is the one quality most often waved through on the builder's own say-so — which is exactly the trap doctrine 1 (build ≠ verify) and doctrine 3 (spike first) exist to close. This guide gives feel a spec so a defect is "misses the bar," not an opinion.
2. **Juice bolted on late.** Treating responsiveness and feedback as a final polish pass instead of a budget designed in from the blockout. Feel that is retrofitted fights the architecture; feel that is planned rides it. A laggy tick-everything mechanic cannot be juiced into feeling good after the fact.

## What "game feel" is
Steve Swink's working definition: **"real-time control of virtual objects in a simulated space, with interactions emphasised by polish."** Three parts, in priority order:
- **Real-time control** — the player acts and the game responds inside a *correction cycle* (read feedback → decide → act → new feedback) of **under ~100 ms**. This is the load-bearing part: if control is not responsive, no amount of polish saves it.
- **Simulated space** — movement, collision, weight, gravity, momentum. The physical rules the player's actions play against.
- **Polish** — "the interactive impression of physicality created by the harmony of animation, sounds, and effects with input-driven motion." The amplifier, never the substitute.

Swink adds **metaphor** (motion carries emotional meaning and familiarity) and frames the whole as six elements: input, response, context, polish, metaphor, rules. Great-feeling games deliver an *aesthetic sensation of control* — the pleasure is in the manipulating, before any goal.

## PRINCIPLES
The craft rules that hold across every mechanic. Sections below tell you the numbers; these tell you what good feels like.
- **Control is the feel.** The input→response loop is the whole game in miniature. A responsive plain mechanic beats a juicy laggy one every time. Fix responsiveness first; add juice second.
- **Every action gets a reaction, inside the correction cycle.** Press, and something perceptible happens within ~100 ms — animation start, sound, a camera nudge, *anything*. Silence reads as a dropped input even when the input landed.
- **Forgive the player — honour intent over simulation truth.** The player's *intention* is the ground truth, not the physics frame. Coyote time, input buffering and generous hitboxes exist because the simulation is stricter than human perception. Forgiveness reads as "responsive and fair"; its absence reads as "the game cheated me."
- **Good-feeling is not realistic.** Tune curves for how they feel, not for physical accuracy. Real gravity feels floaty; game gravity is often several times Earth's. Instant-feeling acceleration is not physical. Serve the feel.
- **Restraint — juice has a peak, and past it more hurts.** A controlled study (Kao et al.) is commonly cited for *medium and high* juiciness outperforming *extreme* juiciness on player experience `[verify — web pass]`. Screenshake, particles and hit-stop are seasoning; over-salted, they obscure the read and induce fatigue.
- **The camera is part of the controls.** A camera that lags, leads and kicks *with* the player amplifies feel; a camera that fights the player destroys it faster than any input bug.
- **Prove it in a spike, felt, before production.** A mechanic that has not been felt is a guess (doctrine 3). Build it in an isolated throwaway map, tune by playing, get a fresh review, *then* integrate.
- **Data-drive every number.** Acceleration, coyote window, shake magnitude, hit-stop frames — all live in tuning tables owned by `game-designer`, never hardcoded. Feel is found by iterating numbers; iteration dies if a recompile stands between each try.
- **Feel lives on the client; authority lives on the server.** Responsiveness demands the client react *now*; correctness demands the server decide. The reconciliation of those two is client prediction, not a choice between them — see the GAS section.
- **The frame budget is sacred.** Feel is a per-frame phenomenon; a hitch is the loudest feel defect there is. Event-driven over tick — every `Tick` you add is spent against 16.6 ms.

---

## Responsiveness & input — "control is the feel"
The single most important axis. Everything else is amplitude on top of a signal that has to arrive first.

**The latency budget.** Total latency is *button-to-pixel*: input poll → game logic → render → display. Swink's correction cycle sets the outer bound — feedback within **~100 ms** reads as "in control." Practical targets, starting numbers to prove by feel:
- **Under ~50 ms button-to-pixel** reads as tight/instant; competitive action aims here.
- **~50–100 ms** is acceptable for most action; the player feels connected.
- **Over ~150–200 ms** reads as sluggish, floaty, or "input lag" — the mechanic feels broken regardless of how it looks.
- Every frame counts: at 60 fps one frame is **16.6 ms**, at 120 fps **8.3 ms**. A two-frame processing delay is a third of your instant-feel budget. Do not spend frames you don't have to (see the frame-budget section).

**Input buffering — never drop a press.** Store an input for a short window so a press made slightly too early still fires when the action becomes legal (e.g. a jump pressed just before landing, an ability pressed during a recovery frame). Consume the buffered input the instant the gate opens, then clear it. Starting windows: **~100–150 ms** (roughly 6–9 frames at 60 fps). Braid is commonly cited as buffering as long as **0.23 s**, and Mario as caching a press for **1–2 frames** `[verify — web pass]` — the range is wide, so tune by feel per mechanic.

**Coyote time — forgive the edge.** A grace window after the character leaves a ledge during which the jump still fires, bridging the gap between perception and physics. Starting windows by feel target:
- Tight precision platforming: **coyote ~70–100 ms, buffer ~70–110 ms**.
- Action / general traversal: **coyote ~90–140 ms, buffer ~100–150 ms**.
- Forgiving / casual: **coyote ~110–170 ms, buffer ~120–180 ms**.
- Celeste — a byword for best-in-class feel — is commonly cited as using a **5-frame** (~83 ms) coyote window `[verify — web pass]`. These two mechanics are the highest-leverage forgiveness features in traversal; their absence is what makes controls feel like they cheat.

**Variable-height / jump-cut.** Holding the jump goes higher, tapping goes lower — give the player analogue control over a digital button by cutting upward velocity on release (or applying extra gravity once released). This is a core reason Mario feels expressive and Donkey Kong-era controls feel rigid on identical hardware.

**Animation-cancel windows.** Let a committed action be interrupted by a higher-priority intent inside defined frames (cancel an attack recovery into a dodge, a landing into a jump). The window *is* the skill ceiling and the responsiveness at once: too tight feels unresponsive, too loose feels weightless and removes commitment. Author the cancellable frames explicitly; never leave them implicit.

**Design against the correction cycle, not the average frame.** The player perceives the *worst* latency, not the mean. A mechanic that responds in 40 ms most frames but 180 ms when a system spikes feels like the 180 ms. Budget for the spike.

## Movement feel — the curve, not the constant
Movement feel is almost entirely in the *transitions* — how speed is gained and lost — not the top speed.
- **Acceleration and deceleration are separate curves, usually asymmetric.** Snappy characters accelerate fast and decelerate faster (little slide); heavy characters ramp both. The ratio between them *is* the character's weight. Tune them independently; a single "speed" value cannot feel right.
- **Friction / braking.** Ground friction sets how the character settles to rest; a touch of slide reads as momentum, too much reads as ice. Distinct from air friction.
- **Air control.** How much steering authority the player keeps mid-jump. Realistic is near-zero and feels terrible; most good-feeling games give substantial air control because the *intent* to adjust is the player's, and honouring it reads as responsive. Serve the feel, not the physics.
- **Gravity is a feel knob, not a constant.** Game gravity is routinely multiples of Earth's — surveys are commonly cited putting Super Meat Boy at roughly **4×** and Super Mario Bros at roughly **9×** Earth gravity `[verify — web pass]`. Higher gravity plus higher jump force gives a snappy, weighty arc; low gravity feels floaty. A **terminal velocity** makes descents predictable and controllable.
- **Fasterholdt et al. catalogue ~21 parameters** for 2D-platformer movement alone (speed, acceleration, friction, braking, jump force, air friction, gravity up/down, terminal velocity, coyote time…). The lesson is not the exact count — it's that movement feel is a *space of many small interacting numbers*, found by iteration in a spike, and therefore must be data-driven.
- **In UE:** `CharacterMovementComponent` exposes most of these (`MaxAcceleration`, `BrakingDecelerationWalking`, `GroundFriction`, `AirControl`, `GravityScale`, `JumpZVelocity`). Expose the ElseCity-relevant ones to a tuning table rather than tweaking the CDO by hand, so designers iterate without a recompile.

## Juice & feedback — the amplifier
Juice makes a landed action *feel* landed. It never replaces the response — it emphasises one that already arrived. This section owns *how* feedback lands; *what* the reward is and *how often* it pays out — the reward schedule — is `game-design`'s call (`guides/game-design.md`). The canonical toolkit (Nijman's *Art of Screenshake*; Jonasson & Purho's *Juice it or lose it*):

- **Hit-stop / hit-pause.** Freeze both actors for a few frames on a heavy impact — the single most effective impact-feedback technique known (the survey calls it "maybe the best-researched phenomenon" in impact feel). It sells weight and force by stealing time. Starting range: **~2–6 frames** (~33–100 ms) scaled to hit strength; a light hit gets none. Too long and the game feels like it's stuttering.
- **Screenshake — with a hard ceiling.** A short positional/rotational camera perturbation on impact, decayed by an easing function. It reads as force and makes a small event feel big. **This is the most over-used tool in the box.** Keep it short, scale it to event magnitude, decay it smoothly, and give the player an option to reduce it (accessibility + motion sickness). Constant or oversized shake is nausea, not feel — recall the Kao result: extreme juice *loses*.
- **Particles, SFX, animation — the harmony.** Polish is the *coincidence* of animation, sound and effect on the same frame as the response. A spawn of particles, a punchy transient sound, and a snap of animation firing together read as one physical event. Any one alone is thin; all three misaligned in time read as mush. Land them on the response frame.
- **Squash-and-stretch.** Deform on acceleration and impact — squash on landing, stretch on launch — then snap back. Cheap, animation-principle-old, and enormously effective at conveying weight and energy without a single extra input frame.
- **Permanence / consequence.** Nijman's point: leave a mark. Impacts that dent, decals that persist, debris that settles — the world remembering the action is feedback that the action mattered.

**Camera feel — lag, lead, kick.** The camera is a controller amplifier:
- **Lag / smoothing** — the camera trails the character with easing rather than rigidly locking, giving motion a sense of weight. Too much and aiming/traversal feels underwater.
- **Lead / look-ahead** — the camera biases toward where the player is moving or facing, showing them where they're going before they get there. This is a *readability* and a *feel* win at once.
- **Kick / impulse** — a small directional camera punch on a heavy action (fire, impact, dash), distinct from omnidirectional shake, that points the emphasis.
- The failure mode is a camera that *fights* the player — snapping, overshooting, or contradicting input. A camera that fights input destroys feel faster than any other single defect, because it corrupts the correction cycle at the perception end.

## Feel-forward abilities on GAS
ElseCity abilities are GAS + gameplay tags, server-authoritative (the player owns the kit; the zone decides what works via allow/block/override; `CanActivateAbility` on the server is the source of truth). The feel challenge is that **authority is remote but feedback must be immediate** — resolve it with prediction and cues, not by weakening authority.

- **Client prediction is how feel and authority coexist.** The client plays the activation, animation, cost and cue *locally and immediately* on a predicted key; the server validates and either confirms (seamless) or rejects (the client rolls back). The player feels the ability fire in the correction cycle; the server still decides. Never make the player wait for a server round-trip to see their own ability start — that is a guaranteed feel defect at any real ping.
- **Gameplay Cues are the feedback channel — keep them cosmetic.** Route particles, sounds, camera kick and hit-stop through Gameplay Cues so they fire on prediction and replicate to observers, and so they carry **zero authoritative state**. A cue that gates gameplay is a bug; a cue is feel, not truth.
- **Tags gate activation; keep the gate cheap.** Zone allow/block/override and ability state read as tag queries. The feel cost to watch for is a *rejected* activation feeling dead — if the zone blocks an ability, the block needs its own immediate feedback (a denied sound/flash) or the player reads it as input lag, not as "not allowed here."
- **The engine facts live in one place — do not duplicate them here.** GAS's Iris support, the ASC-on-PlayerState relevancy behaviour, `EGameplayEffectReplicationMode::Mixed`, and what needs (and doesn't need) build wiring are all in **`guides/unreal-engine.md` §3** with source citations. Read them before wiring an ability; anything networked pairs with `network-engineer` and every activation surface goes to `security-reviewer`.

## The per-frame budget — feel is measured in frames
Feel is a per-frame phenomenon and a hitch is the loudest feel defect there is — a single dropped frame is felt more sharply than a slightly-wrong curve.
- **The budget is fixed:** 60 fps = **16.6 ms/frame**, 120 fps = **8.3 ms/frame**. On a dedicated server this is also the authority tick; a server hitch delays every client's confirmation and reads as lag on every machine.
- **Event-driven over tick, always.** Do not `Tick` to poll a state that could fire an event. Every per-frame `Tick` on every instance is spent against the budget whether or not anything changed. Timers, delegates, GAS tag-change callbacks and input events replace almost all polling.
- **If you must tick, tick coarse and tick few.** Raise tick intervals, tick on a budget, disable tick when idle, and never tick cosmetic-only logic on the server (`FApp::CanEverRender()` is false under `UE_SERVER` — gate client-only feel work off it).
- **Measure, don't assume.** `stat unit` / `stat game` for frame time; the mechanic that feels bad may be a GC spike or a tick storm, not the curve you were tuning. Perf validity caveat: PIE and `-server` run `WITH_EDITOR=1`, so they are valid for *correctness* of feel logic but **not** for shipping frame numbers (see `guides/unreal-engine.md` §1).

## QUALITY BAR
A mechanic is ready to recommend when all of these hold — proven by being *felt* and judged by a fresh pass (`qa-*` for broken, a fresh reviewer for good), never self-signed:
- **Responsive.** Every input produces perceptible feedback within the correction cycle (~100 ms); button-to-pixel is inside the target band for the mechanic's class, and holds *at the worst frame*, not just the average.
- **No dropped inputs.** Presses made slightly early or during a busy frame are buffered and honoured; edge cases (coyote time) forgive the perception/physics gap. The player never says "I pressed it and nothing happened."
- **Movement reads as intended weight.** Acceleration/deceleration/friction/air-control curves convey the character's mass; snappy is snappy and heavy is heavy, walked under gravity and collision — not judged from the fly-cam.
- **Feedback is present, harmonised, and restrained.** Animation, sound and effect land together on the response frame; hit-stop and shake scale to event magnitude and sit *below* the fatigue/nausea ceiling. Turning juice off still leaves a responsive mechanic underneath.
- **The camera amplifies, never fights.** Lag/lead/kick serve the action; the camera never snaps, overshoots, or contradicts input.
- **Abilities fire on prediction.** The player sees their own ability start immediately; the server remains authoritative; a blocked activation has its own immediate feedback.
- **Within the frame budget.** No hitch introduced; no new per-frame `Tick` that an event could replace; server pays for no cosmetic-only work.
- **Data-driven.** Every feel number lives in a tuning table, and was found by iterating in a spike — not hardcoded, not guessed.
- **Felt and reviewed.** Proven in an isolated spike, tuned by playing, and signed off by someone who did not build it.

## COMMON FAILURE MODES
- **Input lag / unresponsive controls.** Feedback arrives outside the correction cycle. → cut the button-to-pixel chain; react on the frame of input; predict client-side rather than waiting on the server.
- **Dropped inputs.** A press made a frame early, or during a recovery/landing, is discarded. → input buffering; consume-and-clear when the gate opens.
- **No coyote time / unforgiving edges.** Jumps eaten at ledge edges; the game feels like it cheats. → coyote window tuned to the feel class.
- **Floaty or twitchy movement.** One "speed" value doing the job of separate accel/decel/friction curves; realistic gravity mistaken for good gravity. → asymmetric accel/decel; gravity and jump force tuned as feel knobs, not physics.
- **No feedback on actions.** An action fires but nothing animates/sounds/moves the camera — reads as a dropped input even when it landed. → a perceptible reaction on every action, on the response frame.
- **Screenshake / juice overuse.** Constant or oversized shake, particle spam, hit-stop on every trivial hit — nausea and fatigue, and the read is buried. → scale to magnitude, decay smoothly, respect the ceiling (extreme juice measurably *loses*), offer a reduce-motion option.
- **A camera that fights the player.** Snapping, overshoot, contradicting input, too much smoothing. → lag/lead/kick that serve the action; the camera is part of the controls.
- **Waiting on the server to feel your own ability.** Activation blocked behind a round-trip; a zone-blocked ability that just feels dead. → client prediction with cosmetic cues; immediate feedback on denial.
- **Tick-everything perf sinks.** Per-frame polling that hitches the frame; the mechanic feels bad because the frame stutters, not because the curve is wrong. → event-driven; measure with `stat unit`; gate cosmetic work off the server.
- **Feel asserted, never felt.** "Feels good" with no spike, no numbers, no fresh review. → the whole reason this guide exists: spec it, spike it, measure it, have someone else judge it.

## CHECKLIST
**Before building (spec):**
- [ ] The feel target is named in words a reviewer can check ("snappy and weighty", "floaty and forgiving") and mapped to a class (tight / action / forgiving).
- [ ] Latency, buffer and coyote target bands chosen for that class.
- [ ] Every feel number placed in a tuning table owned by `game-designer` — none hardcoded.
- [ ] The isolated spike map exists; this is not being tuned in the main build (doctrine 3).

**During the spike:**
- [ ] Responsiveness proven first — feedback inside the correction cycle at the *worst* frame, before any juice is added.
- [ ] Inputs buffered; edges forgiven (coyote); no press droppable by early timing or a busy frame.
- [ ] Accel/decel/friction/air-control/gravity tuned as separate knobs, by playing, under gravity + collision.
- [ ] Feedback harmonised on the response frame; hit-stop and shake scaled and under the ceiling; a reduce-motion path exists.
- [ ] Camera lag/lead/kick tuned to amplify, verified not to fight input.
- [ ] Abilities fire on client prediction; cues carry no authoritative state; blocked activation has immediate feedback (paired with `network-engineer`; surface to `security-reviewer`).
- [ ] `stat unit` clean — no hitch, no new avoidable `Tick`, no cosmetic work on the server.

**Before recommending integration:**
- [ ] Quality bar met, *felt*, not inferred from a green tool result.
- [ ] Compiled with real pass/fail confirmed; new reflected types got a full build + restart.
- [ ] Judged by a fresh reviewer who did not build it (`creative-review` for "is it good"; `qa-*` for "is it broken"; `qa-network` if it replicates).
- [ ] Tuning tables committed; provenance of any borrowed values noted.
- [ ] One-line integration recommendation to the Producer — never a self-integrate into the main build.

## Sources
Craft grounded in the standard game-feel literature:
- **Steve Swink**, *Game Feel: A Game Designer's Guide to Virtual Sensation* (Morgan Kaufmann) — the definition, the correction cycle / ~100 ms threshold, the six elements, polish-as-amplifier.
- **Fasterholdt, Pichlmair & Holmgård**, *You Say Jump, I Say How High? Operationalising the Game Feel of Jumping* (the ~21-parameter model, gravity/terminal-velocity figures, button-caching examples).
- **Jan Willem Nijman (Vlambeer)**, *The Art of Screenshake* (GDC/INDIGO talk) — hit-pause, screenshake, permanence, "more of everything" and its limits.
- **Martin Jonasson & Petri Purho**, *Juice it or lose it* (juice as emphasis on an existing response).
- **Kao et al.**, controlled study of juiciness — *medium/high* juiciness outperforms *extreme*: the empirical basis for restraint.
- **"Designing Game Feel: A Survey"** (Pichlmair & Johansen, arXiv 2011.09201) — consolidates response thresholds, movement parameters, and impact-feedback research.
- **GameJuice**, *Coyote Time, Input Buffering, and the Art of Forgiving Controls* — the per-class timing bands.
- Referenced best-in-class controls: **Celeste** (5-frame coyote window), **Super Mario Bros.** (variable jump, state-dependent response), **Super Meat Boy** (movement tuning).

Engine-behaviour facts (GAS under Iris, ASC relevancy, replication modes, the `WITH_EDITOR` perf caveat) are **not** duplicated here — they live with their source citations in `guides/unreal-engine.md` §1 & §3.
