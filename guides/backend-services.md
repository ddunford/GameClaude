# Guide — Backend & online-services craft (the persistent backbone)

> Read before designing anything durable, account-scoped, transactional, or fleet-level. The core idea: **the game server is authoritative to the client — and this layer is authoritative to the game server. Everything a persistent social world remembers lives here: who you are, what you own, what you built, and where you are placed. It is done when durable state cannot be duplicated, lost, or written on anyone's unverified word — and when the schema it all hangs on can grow without a migration.**

Authority *inside a session* — position, ability activation, relevancy — is `agents/network-engineer`'s and `guides/networking.md`'s. The *rules* of the economy — faucets, sinks, the numbers — are `agents/game-designer`'s and `guides/game-design.md`'s. **This guide owns the layer between them:** the durable read/write behind the game server, the account it writes against, the atomic transaction that moves a coin, who gets placed into which instance, and the fleet the servers run on. Engine facts — OnlineSubsystem/EOS, and the dedicated-server target a Launcher build cannot link (`guides/unreal-engine.md §1`) — live in `guides/unreal-engine.md` and are **linked, verified via `agents/engine-verifier`, never restated**.

## The two failures this prevents
1. **The schema retrofit.** The account/save/ownership schema is committed late, after the systems that depend on it are built — so it encodes wrong assumptions, and fixing it forces a live data migration across every player's save. The persistence schema shapes the save format and every server-authoritative system; it is a Phase-1 decision, not a Phase-2 one (`guides/production-pipeline.md §3.5`).
2. **The dupe / the silent loss.** A currency or item mutation that is not atomic and idempotent. A retried request grants twice (a dupe — economy-destroying), or a partial write on a crash takes an item without granting its counterpart (a loss — trust-destroying). In a persistent creator economy neither is survivable.

## PRINCIPLES
The craft rules that hold across every service. They sit *on top of* never-trust-the-client (doctrine 11), extended one hop: to this layer, **the game server is a client too** — a compromised or buggy server must not be able to corrupt durable state either.
- **Server-authoritative all the way down.** The game server is authoritative to the game client; the services layer is authoritative to the game server. Nothing durable is written on a client's word, and the server's request is validated against its own rights before it is honoured.
- **Every economic mutation is a transaction — atomic, idempotent, auditable.** ACID semantics for anything touching currency, inventory, ownership, or progression. Every mutating call carries an **idempotency key** so a retry over a lossy network cannot double-apply. An **append-only ledger is the source of truth; balances are a projection** you can always rebuild by replaying the log.
- **The schema is a long-lead contract — design it before what depends on it.** Version every persisted structure from the first commit; ship a forward-migration for every schema change; never break a save a player already has. A schema you cannot migrate is a schema you cannot change.
- **Idempotency and exactly-once intent over an at-least-once network.** Clients and servers retry on timeout, so every mutating endpoint is designed to be safe to call twice with the same key and produce the effect once.
- **Stateless services; state in the datastore.** Service processes hold no session-critical state in memory, so any instance can serve any request and the tier scales horizontally. The datastore is where truth lives; the service is a validator and router.
- **Separate identity from game-state from the ledger.** Accounts (PII, auth), game state (saves, inventory), and the financial ledger have different consistency, retention, and compliance needs — accounts touch PII and pull in legal/compliance; the ledger is append-only and audited. Do not fuse them into one store.
- **Fail safe, never fail open.** On a datastore error, timeout, or ambiguity, **deny** the mutation. A dropped write must never leave currency granted or an item duplicated. The safe default for money is "the transaction did not happen."
- **Measure against a budget: concurrency, latency, cost.** Concurrent connections (the hard Iris cap is 128 per game server — `guides/unreal-engine.md §3`), request latency at the datastore, and per-player storage/cost are first-class constraints with numbers, not "it works in dev."

## 1 — Accounts & identity
The account is the root every durable thing hangs off — ownership, entitlements, progression, moderation history. Get it wrong and everything downstream inherits the mistake.
- **Identity via the Online Subsystem.** Unreal's `IOnlineSubsystem` / EOS (Epic Online Services) provides identity, auth tokens, and friends/presence [verify — web pass: current EOS auth flow and OSS interface names]. Prefer the platform's identity to a hand-rolled one; treat the auth token as the credential and validate it server-side on every session.
- **The account is the ownership root.** Entitlements, inventory, created worlds, and currency are scoped to an account id, never to a device or a session. A session is transient; the account is durable.
- **Isolate PII.** Email, payment identity, age-verification status, and real-name data live behind a boundary with its own access control and retention policy — this is where legal/compliance and `agents/trust-safety`'s age-gate meet the datastore. The game state store should reference an account id, not carry PII.
- **Auth is re-checked, not trusted once.** A session token is validated on connect and re-validated for privileged actions; a stale or spoofed token is hostile input (`agents/security-reviewer`).

## 2 — Persistence & save infrastructure
What the world remembers between sessions, and the format it remembers it in.
- **Decide what is durable.** Position/velocity are session state (`network-engineer`); inventory, currency, progression, created worlds, social graph, and moderation history are durable. Draw the line explicitly — over-persisting is cost and migration risk, under-persisting is lost player progress.
- **Version and migrate from day one.** Every persisted record carries a schema version; every schema change ships a forward migration; a player's old save always loads. This is the direct defence against failure #1 — the retrofit is only forced when versioning was skipped.
- **The save-on-unload join with networking.** ElseCity runs World Partition with server streaming; **unloading a server cell destroys its actors, which is authoritative state — data loss.** So `wp.Runtime.EnableServerStreamingOut` stays `0` until this layer provides **persistence-on-unload**: the authoritative state of a cell is durably written *before* the cell can be streamed out. Re-enabling destructive streaming without it is the loss failure at world scale. (Mechanism: `guides/unreal-engine.md §3`; the cvar rule is settled.)
- **The read/write path.** The game server reads a player's durable state on join and writes it back on change and on leave — batched and event-driven, never a per-tick poll. A save write is a transaction (§3) when it touches anything economic.

## 3 — Transactions & the economy ledger
The heart of the trust model. `game-designer` sets what a coin is worth; this layer guarantees the coin cannot be forged or lost.
- **ACID for anything economic.** A currency spend, an item grant, a trade, a payout: each is a transaction that either fully commits or fully rolls back. A trade is the canonical case — A loses gold and B gains the item, or neither happens; never one without the other.
- **Idempotency keys.** Every mutating request carries a client- or server-generated unique key; the ledger records applied keys; a replay of the same key is a no-op that returns the original result. This is what makes a retry safe and kills the retry-dupe.
- **Append-only ledger as source of truth.** Model money movement as **double-entry**: every mutation is a pair of entries that sum to zero, written append-only. Balances are a *projection* over the ledger, cacheable and always rebuildable. An append-only log is also the audit trail `agents/trust-safety` and compliance need.
- **The creator economy is two-sided.** Value flows creator ↔ visitor ↔ platform. The ledger records all three legs; actual **payout** (money out to a creator) and its tax/KYC surface belong to `guides/monetization.md` and legal — this layer provides the atomic, auditable movement they build on.
- **Reconciliation.** Periodically prove the projected balances equal the ledger sum; a divergence is a bug or an exploit and is alarmed on, not silently corrected.

## 4 — Matchmaking & session brokering
Placing a player into the right server instance, and managing the session lifecycle.
- **ElseCity's topology sets the problem.** Districts are regions inside **one** server instance (zone-sharded — never server meshing, never a boundary at a street); **zones behind doors are their own maps and their own instances.** So brokering answers: which instance serves this district, does it have capacity (the 128-connection cap — `guides/unreal-engine.md §3`), and how does a player crossing a door get placed into the target zone's instance.
- **The door is a session handoff.** A door transition (a chokepoint — metro/lift/tunnel/door, never mid-street) is, at this layer, a brokered move from one instance to another: reserve a slot on the target, hand off the player's durable state, connect, release the source slot. It is also a client-reachable transition — eligibility (age-gate, paid, progression) is re-derived server-side, never trusted (`agents/security-reviewer`, and `agents/trust-safety` for the age-gate policy).
- **Sessions have a lifecycle.** Create → fill → drain → tear down, with capacity, health, and a graceful drain that persists state before shutdown. A crashed instance must not strand players or lose their durable state (fail safe — §Principles).

## 5 — Dedicated-server fleet orchestration
The game servers are not one box; they are a managed, scaled, health-checked fleet.
- **Provisioning & allocation.** A pool of dedicated-server processes, allocated to sessions on demand, scaled with population. The allocator answers "give me a healthy server for district X with N free slots."
- **The Launcher-build constraint is real and current.** The `ElseCityServer` target **cannot link on a Launcher (installed) engine build** — the engine ships no server-flavoured libraries. PIE-as-client and `-server` run `WITH_EDITOR=1` and are valid for *authority/replication correctness* but **not for shipping performance or a real fleet**. A source-built engine (or Epic's dev container) is on the critical path to at-scale multiplayer testing — this is `guides/unreal-engine.md §1`'s and `build-release`'s to own; honour it and never quote a PIE figure as a fleet number.
- **Health, scaling, and cost.** Health checks, autoscale on population, graceful drain on scale-down (persist first — §2/§4), and a cost model per concurrent player. Fleet cost is a real constraint on a persistent world's viability — surface it.

## 6 — Scale & the data tier
- **Datastore choice is a trade-off, made deliberately.** Strong-consistency relational for the ledger and accounts (money and identity want ACID); a lower-latency key-value or document store for hot game state; possibly a cache tier in front. Pick per data class, not one store for everything [verify — web pass: current managed-datastore options and their consistency guarantees].
- **Shard and replicate for scale.** Read replicas for read-heavy paths; sharding by account/region for write scale; the ledger's append-only shape shards more easily than mutable balances.
- **Cache with an invalidation story.** A balance projection is cacheable, but the cache is not authority — the ledger is. Every cache has a defined invalidation and a fallback to source.
- **Do the math up front.** Storage per account × population, writes/sec at peak, datastore latency in the join path. "Fine with two devs" is not a scale result.

## 7 — The security lens (the view over everything above)
Doctrine 11, extended: the game server is a client to this layer, and both are hostile until proven.
- **Every service endpoint is authenticated and validated.** Service-to-service auth for the game-server→services calls; a compromised game server must not be able to grant itself currency or read another account's PII.
- **Every client-supplied value is hostile** even when it arrives via the game server: item ids, quantities, target accounts, idempotency keys, session tokens, transition eligibility. Re-derive, range-check, and reject; each check names the exploit (`harden-endpoint`, `agents/security-reviewer`).
- **Rate-limit and quota.** A mutating endpoint that can be hammered is a dupe attempt or a DoS; rate-limit per account and alarm on anomalies.
- **Hand every service endpoint to `agents/security-reviewer`** before it ships, and every schema/transaction change to review — the transaction path is the highest-value target in the game.

## QUALITY BAR
A backend system is ready to recommend when all of these hold — verified, never self-signed:
- **Authoritative.** No durable state is written on a client's — or an unvalidated server's — word; on error the system fails safe (denies), never open (grants).
- **Atomic & idempotent.** Every economic mutation fully commits or fully rolls back; a retried request with the same idempotency key applies once; a trade is all-or-nothing.
- **Auditable.** An append-only ledger is the source of truth, balances reconcile to it, and the trail satisfies moderation/compliance retention.
- **Migratable.** Every persisted structure is versioned and has a forward migration; an old save always loads; no schema change forces an un-migrated break.
- **Loss-safe at world scale.** Destructive server streaming is off until persistence-on-unload writes a cell's authoritative state before it can unload.
- **Placed correctly.** Matchmaking respects the zone topology and the connection cap; a door transition hands off durable state cleanly and re-derives eligibility server-side.
- **Fleet-honest.** Fleet and scale numbers come from a source-built/cooked path, not from `WITH_EDITOR=1` PIE; capacity, health, drain, and cost are specified.
- **Scale-measured.** Datastore choice, sharding/replication/caching, and the per-account and peak-write math are written down and measured against a budget.
- **Audited.** Every service endpoint and the whole transaction path have been through `agents/security-reviewer`.

## COMMON FAILURE MODES
- **Schema retrofit.** Account/save schema committed after dependent systems, forcing a live migration on every player's save. → design and version the schema in Phase 1, before the systems that hang off it.
- **Retry dupe.** A timed-out mutating request retried without an idempotency key, applying twice — free currency. → idempotency key on every mutating call; ledger records applied keys.
- **Non-atomic trade / partial write.** A crash mid-mutation grants one leg of a trade and not the other — a dupe or a loss. → ACID transaction; all-or-nothing; double-entry ledger.
- **Balance-as-truth.** Treating a mutable balance field as authority, so a bad write silently corrupts it with nothing to reconcile against. → append-only ledger is truth; balance is a rebuildable projection.
- **Fail open.** On a datastore error the code grants the reward "to be safe for the player" — and the exploit is to force the error. → fail safe: error denies the mutation.
- **Destructive streaming with no persistence.** `EnableServerStreamingOut=1` before save-on-unload exists — a cell unloads and authoritative state is gone. → keep it `0` until persistence-on-unload lands.
- **Stateful service.** Session-critical state kept in a service process's memory, so it can't scale horizontally and a restart loses state. → stateless services, state in the datastore.
- **PII fused into game state.** Email/payment/age data mixed into the save store, spreading a compliance and breach surface across everything. → isolate identity/PII behind its own boundary.
- **Trusting the game server.** Assuming the game server's requests are safe because it's "ours" — a compromised or buggy server then corrupts the ledger. → validate service calls; the server is a client too.
- **Fleet numbers from PIE.** Quoting `WITH_EDITOR=1` PIE capacity/latency as a shipping fleet figure. → fleet numbers come from the source-built/cooked path only (`guides/unreal-engine.md §1`).

## CHECKLIST
**Design (before building):**
- [ ] Durable-vs-session state line drawn explicitly; every durable structure has a schema version and a forward-migration plan.
- [ ] Identity/auth model chosen (OSS/EOS `[verify]`); account is the ownership root; PII isolated with its own access/retention.
- [ ] Every economic mutation specified as an atomic, idempotent transaction with an idempotency key; ledger is append-only double-entry; balances are a projection.
- [ ] Matchmaking/session brokering respects the zone topology and the 128-connection cap; the door handoff persists state and re-derives eligibility server-side.
- [ ] Fleet lifecycle (provision/allocate/health/drain/scale/cost) specified; the source-build requirement for real fleet numbers acknowledged.
- [ ] Datastore choice per data class; sharding/replication/caching plan; per-account and peak-write math written down.
- [ ] Fail-safe-not-open decided for every mutation path.

**Build:**
- [ ] Services stateless; all durable state in the datastore.
- [ ] Idempotency and ACID enforced on every mutating path; reconciliation of balances to ledger implemented and alarmed.
- [ ] Persistence-on-unload in place before any destructive server streaming is enabled.
- [ ] Every client- and server-supplied value validated and range-checked; each check names its exploit (`harden-endpoint`).

**Before recommending done:**
- [ ] Quality bar met.
- [ ] Handed to `agents/security-reviewer` (every service endpoint + the whole transaction path) — not self-signed.
- [ ] Migration tested against a prior-version save; a retried mutation proven to apply once; a mid-transaction failure proven to roll back fully.

## Sources
Craft grounded in the standard distributed-systems and online-services literature; specifics to re-confirm on the web pass are tagged `[verify — web pass]`:
- **Idempotency & exactly-once over an at-least-once network** — the retry/idempotency-key pattern (Stripe's idempotency-keys model is the widely-cited reference) `[verify — web pass]`.
- **Double-entry / append-only ledgers as financial source of truth** — the accounting-ledger pattern applied to game/virtual economies `[verify — web pass]`.
- **ACID & the datastore-per-data-class trade-off** — standard database-systems guidance; managed-datastore options and their consistency guarantees `[verify — web pass]`.
- **Dedicated-server fleet orchestration & allocation** — the game-server-fleet allocation pattern (Agones / managed game-server-hosting model) `[verify — web pass]`.
- **Epic** — Online Subsystem / EOS identity, sessions, and dedicated-server hosting; interface names and the current EOS auth flow `[verify — web pass]`. Engine-specific facts (OSS/EOS, the dedicated-server target and the Launcher-build link constraint, server streaming) are owned by `guides/unreal-engine.md` and verified via `agents/engine-verifier`.
