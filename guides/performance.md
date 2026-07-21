# Guide — Performance engineering (frame · memory · bandwidth budgets)

> Read before setting a budget, profiling a scene, or gating a build on perf. The core idea: **performance is a budget decided up front and measured against, never a cleanup pass at the end — and a perf number is only real on a representative build.** Perf debt compounds; a late pass on a locked build pays for itself in content cuts.

## The two failures this prevents
1. **Perf as an end-of-project pass.** Budgets undeclared until the frame rate is already bad, then a scramble to claw it back by cutting content that was built to the wrong assumption. Budgets are set in Phase 1 and every discipline builds to them (`guides/production-pipeline.md §3.5`); the perf pass *enforces* a budget, it does not discover one.
2. **Measuring the wrong build.** Quoting a PIE or `-server` frame/bandwidth number as a shipping figure. Both run `WITH_EDITOR=1` on this project and leave cooked-server paths untested — valid for *correctness*, invalid for *performance* (`guides/unreal-engine.md §1`). A perf claim on an editor build is not a perf claim.

## What this discipline owns, and what it borrows
This guide owns the **budget discipline, the profiling method, and the perf gate.** The two heaviest budget domains have their craft homes elsewhere — link, do not restate:
- **The per-frame budget** (16.6 ms at 60 fps, event-driven over tick, hitch-as-loudest-defect, `stat unit`/`stat game`) is owned by **`guides/game-feel.md`** (the per-frame budget section). Perf enforces it as a gate; game-feel explains why a hitch is felt.
- **Bandwidth budgets and their levers** (relevancy, dormancy, update frequency, delta compression, quantization; the ~10 KB/s per-connection cap × 128 connections) are owned by **`guides/networking.md §4`**. Perf tracks bandwidth as a shipping budget; networking explains how to spend it.
- **Engine perf facts** — the `WITH_EDITOR` caveat, server streaming residency (monotonic loaded set, restart-as-only-reset), ISM collision cost on the dedicated server, Nanite reduces per-draw cost not draw calls — all live in `guides/unreal-engine.md` with source citations. Link.

## The three budgets, and ElseCity's specific pressure
- **Frame (GPU + CPU + game thread).** 60 fps = 16.6 ms; the dedicated server's authority tick shares this bound — a server hitch reads as lag on every client (`guides/game-feel.md`). Split the budget explicitly across game thread / render thread / GPU / draw calls, per target platform.
- **Memory (client + server).** On this project server residency is the sharp edge: with server streaming on, the loaded set is **monotonically increasing** and converges on the union of every cell any player has visited — budget server memory against the **full map**, treat a restart as the only reset (`guides/unreal-engine.md §2`). Client memory budgets against streaming pools + texture pools.
- **Bandwidth (per connection × 128).** Design to the per-connection cap × the 128-connection Iris ceiling, never to what localhost PIE tolerates (`guides/networking.md §4`, `guides/unreal-engine.md §3`).

**The compounding pressure unique to ElseCity — measure the interaction, never the axes alone:** open-world streaming × **player density** (a pillar — a city that reads empty at alpha is a failure) × **user-generated geometry** (unbounded, adversarial: "data not code" is not "cheap"). Each axis is fine in isolation; their product is where the frame, the server memory, and the bandwidth all blow at once. Perf budgets must be set and profiled at the **loaded density with UGC present**, not on an empty hub.

## Profiling method
- **`stat unit` first** — it tells you which thread you are bound on (game / render / GPU / draw) before you optimize the wrong one. `stat game`, `stat scenerendering`, `stat rhi`, `Stat Net` for the network side (`guides/networking.md §4`).
- **Unreal Insights for the real trace** — timeline capture across a session catches the GC spike, the tick storm, the streaming hitch that a live `stat` readout averages away. Design against the *worst* frame, not the mean (`guides/game-feel.md`).
- **Measure on a representative build.** Correctness profiling in PIE/`-server` is fine for finding a tick storm or a relevancy mistake; a *shipping* number waits for the cooked build on the source-built engine (`guides/unreal-engine.md §1`) on target hardware.
- **Profile at load.** Empty-scene numbers are marketing. Profile at target player density with UGC and streaming active — the interaction is the budget.

## The perf gate (P3–P4)
Perf is a **verify owner**, not the builder — it gates work out the same way `qa-visual` does. A build fails the perf gate when it misses a declared budget on a representative measurement; the defect is "misses the 16.6 ms game-thread budget at density," not an opinion. The gate never rests on an editor-build number, and the builder never signs off their own perf.

## PRINCIPLES
- **Budget first, enforce later.** Numbers are chosen in P1 and committed; the P3–P4 pass measures against them. No budget = no gate = perf debt.
- **Measure, never assume.** The thing that feels slow is rarely the thing that is slow. `stat unit` / Insights before any optimization; re-measure after.
- **Representative build or the number is a lie.** WITH_EDITOR builds are for correctness; shipping numbers need the cooked build on target (`guides/unreal-engine.md §1`).
- **Profile the interaction.** Streaming × density × UGC together — the product is the budget, not any single axis.
- **Event-driven over tick, everywhere.** Every per-frame `Tick` is spent against 16.6 ms whether or not state changed; the server pays for no cosmetic-only work (`guides/game-feel.md`).
- **Optimize the bound, not the convenient.** Fix the thread you are actually bound on; a GPU win on a game-thread-bound frame buys nothing.
- **Perf is a gate, not the builder's opinion.** A fresh perf pass against the committed budget, never self-signed.

## QUALITY BAR
- **Budgets exist and are committed** — frame (split by thread + draw calls), memory (client + server-at-full-map), bandwidth (per-connection × 128), per target platform.
- **Measured on a representative build** at target density with UGC and streaming active — not empty-scene, not an editor build for shipping numbers.
- **Within budget at the worst frame**, not just the average; no hitch introduced by the change under test.
- **Server tick holds** — no server hitch that would read as lag on every client; server residency budgeted against the full map.
- **Bandwidth within the per-connection cap** at target relevancy (`guides/networking.md §4`).
- **No avoidable tick** — event-driven where an event would do; no cosmetic work on the server.
- **Gated fresh** — perf verdict by someone who did not build the thing, against the committed budget.

## COMMON FAILURE MODES
- **No budget.** Perf discovered instead of enforced; content built to the wrong assumption. → set and commit budgets in P1.
- **Editor-build perf numbers.** A PIE/`-server` figure quoted as shipping. → WITH_EDITOR is correctness-only; measure the cooked build on target.
- **Empty-scene profiling.** Great numbers on a hub nobody is in. → profile at density with UGC + streaming.
- **Optimizing the wrong bound.** Hours on GPU while game-thread-bound. → `stat unit` first.
- **Tick storms.** Per-frame polling of state that could fire an event; cosmetic logic ticking on the server. → event-driven; gate client-only work off the server.
- **Unbounded server memory.** Assuming server streaming caps residency — it does not (monotonic loaded set). → budget against the full map; restart is the only reset (`guides/unreal-engine.md §2`).
- **UGC cost ignored.** "Data not code" mistaken for "free" — malicious/heavy geometry blows the frame and the memory. → budget-cap UGC primitives; profile with adversarial content present.
- **Late pass on a locked build.** Perf debt hits at content-lock, forcing cuts. → continuous budget enforcement from P2.

## CHECKLIST
**Setting budgets (P1):**
- [ ] Frame budget split by thread + draw calls, per target platform, committed.
- [ ] Memory budget: client pools + server-at-full-map residency.
- [ ] Bandwidth budget: per-connection cap × 128, per the networking levers.
- [ ] UGC primitive budget caps declared (with `game-designer` / `tech-artist`).

**Profiling a scene / change:**
- [ ] `stat unit` to find the bound before optimizing.
- [ ] Insights trace across a session for spikes the live readout hides.
- [ ] Measured at target density with UGC + streaming active.
- [ ] Re-measured after the change; worst-frame checked, not just mean.

**Perf gate (P3–P4):**
- [ ] Representative cooked build on target hardware (source engine, `guides/unreal-engine.md §1`).
- [ ] Every declared budget met at the worst frame under load.
- [ ] Server tick holds; bandwidth within per-connection cap.
- [ ] Verdict rendered fresh, against the committed budget — never self-signed.

## Sources
- **Epic** — Unreal Insights, `stat` commands, and the [Testing & Optimizing Content / Profiling](https://dev.epicgames.com/documentation/unreal-engine/testing-and-optimizing-your-content) guides. `[verify — web pass]`
- Frame-budget craft: `guides/game-feel.md` (the per-frame budget). Bandwidth craft: `guides/networking.md §4`. Engine perf facts: `guides/unreal-engine.md §1–5`.
- Standard real-time optimization practice (thread-bound diagnosis, worst-frame design, draw-call batching / instancing). `[verify — web pass]`
