# Guide — Real-time VFX method (Niagara)

> Read before authoring or revising any effect. The core idea: **an effect exists to communicate an event and amplify how it feels — never to decorate — and it is done only when it reads at a glance, stays inside a named budget, and never obscures the gameplay it sits on top of, judged by someone who didn't build it.**

## The two failures this prevents
1. **The perf-hog nobody budgeted.** An effect authored for a hero screenshot with an unbounded spawn rate, stacked translucent sprites, and no LOD — beautiful in isolation, a frame-time cliff the moment three of them overlap on screen. VFX is the discipline where "looks great here" and "runs" diverge hardest, because the cost is invisible until the effects stack. A budget makes the cost a number, not a surprise.
2. **Spectacle that fights the game.** Effects so loud, so numerous, or so similar to gameplay-critical cues that the player can no longer read what matters — the telegraph lost in ambient sparkle, the whole screen a particle soup. An effect that reduces clarity has done the opposite of its job, however impressive.

## PRINCIPLES
The craft rules that hold across every effect. Sections below give the Niagara specifics; these say what good looks like.
- **Communicate first, decorate never.** Before authoring, name the event and the message: *something happened* (impact), *something matters* (a pickup, a threat), *go here* (a beacon), *this is alive* (ambient). An effect with no message is cut. Decorative-only FX competes for the same eye and the same frame as the cues the player must not miss.
- **Amplify an event; don't be the event.** Like screenshake and hit-stop (`guides/game-feel.md`), VFX is the amplifier on a response that already arrived — it lands *with* the hit, the ability, the pickup, on the same frame. FX firing without an event to emphasise reads as noise.
- **Restraint — juice with a ceiling.** More particles is not more feel; past a peak, effects fatigue the eye, bury the read, and starve the frame. This is the same measured ceiling `guides/game-feel.md` sets — extreme juice measurably *loses*. Reach for the smallest effect that communicates.
- **Readability outranks spectacle.** A gameplay-critical effect (a telegraph, an enemy tell, an interaction prompt) must out-read every ambient effect around it. Consistent colour/shape/motion language so the player *learns* the vocabulary and reads it under pressure.
- **Budget is designed in, not discovered.** Every effect has a particle-count, overdraw, and GPU-cost ceiling and a set of LODs *before* it ships; culling by distance and significance is part of authoring, not an optimisation pass bolted on when the frame drops.
- **Cosmetic and client-side.** Gameplay FX carries zero authoritative state; it fires on prediction and replicates as cosmetic through GAS Gameplay Cues (`guides/game-feel.md`, `guides/unreal-engine.md §3`). A cue that gates gameplay is a bug, not an effect.
- **Profile, don't guess.** VFX cost is dominated by overdraw and GPU sim/draw, both invisible to the eye and to a particle count. Measure with the Niagara debugger and `stat GPU`; the effect that tanks the frame is rarely the one you'd suspect.
- **Prove it in a spike.** A new effect type is proven in an isolated map — read, budget, and stacking behaviour — before it enters the main build (doctrine 3).

---

## Niagara architecture — the vocabulary

Niagara's hierarchy, so the routing is unambiguous `[verify — web pass: confirm current Niagara terminology and module/stage names for UE 5.x]`:
- **System** — the whole effect asset (a "muzzle flash", a "door-transition burst"), containing one or more emitters. This is the unit you place and budget.
- **Emitter** — one behaviour within the system (the sparks, the smoke, the flash), each with its own **sim target** (CPU or GPU) and its own spawn/update logic.
- **Modules & stages** — the stack that drives an emitter: Emitter Spawn/Update, Particle Spawn/Update, Render. Author behaviour as modules; prefer the built-in modules and dynamic inputs over bespoke scratch modules where they suffice.
- **Renderers** — how particles draw: **Sprite** (billboards — the overdraw risk), **Mesh** (instanced geometry — draw-call and triangle cost), **Ribbon** (trails), **Light** (expensive; budget hard). Choose the cheapest renderer that reads.
- **Parameters & user-exposed inputs** — drive variation from gameplay (colour, scale, intensity) via exposed parameters rather than forking the asset; one system, many looks, is cheaper than many systems.
- **Reuse over one-offs.** A parameterised library system (a generic impact, a generic pickup) beats a bespoke asset per event, exactly as the modular-kit logic holds for meshes (`guides/environment-art.md`).

## GPU vs CPU sim — the call, with the trade named

Pick per emitter, and state why:
- **GPU sim** — for **high particle counts** and cheap-per-particle behaviour (sparks, dust, dense ambient). Runs on the GPU, scales to tens of thousands, but **can't cheaply read back into gameplay logic** and its collision is limited (typically depth-buffer / distance-field based, not arbitrary scene geometry) `[verify — web pass: current GPU-sim collision modes and CPU-readback limitations in Niagara]`.
- **CPU sim** — for **low counts** and anything that must **feed CPU-side data or use full collision** (events that spawn gameplay reactions, precise scene collision, small hero effects). Cheaper to author against gameplay; does not scale to huge counts.
- **The rule:** high count + purely cosmetic → GPU; low count + needs CPU data or real collision → CPU. Name the trade in the effect's notes so a reviewer can check the choice, don't leave it implicit.

## FX materials & overdraw — where the cost actually is

- **Overdraw is the usual killer, not particle count.** Overdraw is the same pixel shaded many times by stacked translucent sprites; a modest count of large, overlapping, translucent particles can cost more than a huge count of small opaque ones. Keep translucent particles small, few, and non-overlapping where possible; prefer additive where it reads; consider opaque/masked with soft edges when translucency isn't essential.
- **Cheap FX materials.** Effect shaders are drawn many times — keep instruction counts low, avoid heavy per-pixel work, use flipbooks/erosion sparingly. A costly material multiplied by thousands of particles is a GPU sink.
- **Soft particles** to avoid hard intersection lines with scene geometry; **erosion/dissolve** for organic fades — both worth their cost when they sell the read, wasteful when they don't.
- **Lights from FX are expensive** — a particle Light renderer or per-effect dynamic light multiplies shading cost; budget them hard, prefer emissive that reads *as* light without being one (echoing `guides/lighting.md`'s emissive-not-lights inside PLAs).

## LOD, scalability & budgets — the ceiling, per effect

Every effect ships with these set:
- **A named budget** — a ceiling on particle count, spawn rate, active-instance count, and (where measurable) overdraw/GPU-µs for the effect at full quality. An unbounded spawn rate is a defect. The budget lives with the effect, checked by the profiler, not asserted.
- **LODs by distance.** Reduce particle count, disable expensive emitters, and simplify materials as the effect recedes; a distant effect needs a fraction of a near one. Use Niagara's scalability/detail settings and significance handling `[verify — web pass: current Niagara scalability, significance handler, and effect-type budget settings]`.
- **Significance & culling.** Cap how many instances of an effect run at once (significance culls the least-important when the budget is exceeded), and cull off-screen/too-distant effects entirely. In a dense social city, the same effect will exist many times over — the per-effect cost times the crowd is the number that matters.
- **Scalability tiers.** The effect degrades gracefully across quality settings; the low tier still reads its message, just with less spectacle. Readability survives at every tier; spectacle is what scales.
- **Fixed bounds** where the system's dynamic bounds would cost more to compute than they save `[verify — web pass]`.

## Readability — the effect must communicate under pressure

- **A consistent visual language.** The same category of event uses a consistent colour/shape/motion so the player learns it: e.g. hostile telegraphs share a language distinct from friendly cues, distinct from ambient life. An effect that looks like a threat but isn't (or vice versa) is a clarity bug.
- **Gameplay-critical out-reads ambient.** A telegraph, an enemy attack tell, an interaction affordance must win the eye against decoration — more contrast, more distinct motion, a reserved colour. Never let ambient sparkle occupy the same visual channel as a cue the player must not miss.
- **Motion draws the eye** (`guides/level-design.md`: contrast and movement pull attention) — spend that pull on what matters and damp it on what doesn't; constant ambient motion everywhere is as blinding as constant brightness.
- **Read it in the register it plays in.** An additive effect that pops against a night sky can vanish against a bright day scene (`guides/lighting.md` day/night); verify readability in both registers, not one.

## Working with GAS — the ability-cue path

ElseCity abilities are GAS + tags, server-authoritative (`guides/game-feel.md`). The VFX consequence:
- **Route ability FX through Gameplay Cues** so they fire on the client's *predicted* activation (immediate feel) and replicate to observers as cosmetics — never wait on a server round-trip to show the player their own effect.
- **Cues carry zero authoritative state.** The effect is feedback, not truth; if the ability is denied by a zone (allow/block/override), the *denial* needs its own immediate cue or it reads as input lag (`guides/game-feel.md`).
- **The engine facts are not duplicated here** — GAS under Iris, cue replication, `WITH_EDITOR` perf caveats live in `guides/unreal-engine.md §3` with citations. Read them before wiring; pair anything networked with `network-engineer`.

## QUALITY BAR
An effect is ready to recommend when all of these hold — judged by a fresh pass (`qa-visual` for reads-and-runs, `creative-review` for on-pitch), never self-signed:
- **Communicates.** The event and message are named; the effect fires *with* its event, on frame; a stranger can say what it means.
- **Reads at a glance, in both registers.** Legible against a bright and a dark background; gameplay-critical effects out-read ambient; the visual language is consistent with its category.
- **In budget.** Particle count, spawn rate, active-instance cap, and overdraw/GPU cost are inside the named ceiling — *measured* with the Niagara debugger / `stat GPU`, not eyeballed — including when the effect stacks in a crowd.
- **LOD'd and culled.** Distance LODs, significance cap, and off-screen culling set; degrades gracefully across scalability tiers with the message surviving at the low tier.
- **Right sim target.** GPU vs CPU chosen per emitter with the trade named; cheapest renderer that reads; overdraw controlled; FX lights budgeted or replaced with emissive.
- **Cosmetic and predicted.** Carries no authoritative state; ability FX fires on prediction via Gameplay Cues; a denied activation has its own cue.
- **Restrained.** The smallest effect that communicates — below the fatigue/nausea ceiling, with a reduce-motion-friendly path where it's screen-dominating.

## COMMON FAILURE MODES
- **Perf-hog FX.** Unbounded spawn rate, stacked translucent overdraw, uncapped instances, no LOD — fine alone, a frame cliff when it stacks. → a named budget; LODs; significance cap; profile overdraw and GPU cost, don't trust particle count.
- **Unreadable / overdone.** Screen-filling particle soup; the message lost in spectacle; extreme juice past the ceiling. → restraint; the smallest effect that communicates; contrast reserved for the read.
- **FX that fights gameplay clarity.** Ambient sparkle in the same channel as a telegraph; an effect that looks like a threat and isn't; motion pulling the eye off what matters. → a consistent visual language; gameplay-critical out-reads ambient; damp decorative motion.
- **No budget.** "It looks fine on my machine" with no ceiling and no profile — the cost discovered when the frame drops in the shipped crowd. → budget before ship; measure; test stacked, not solo.
- **Wrong sim target.** GPU emitter that needed CPU readback/collision (so the gameplay reaction never fires), or a CPU emitter grinding on a count only the GPU should carry. → pick per emitter; name the trade.
- **FX as truth.** An effect gating gameplay, or an ability cue that waits on the server so the player's own effect lags. → cosmetic only; fire on prediction via Gameplay Cues; immediate denial feedback.
- **Judged in one register / solo.** Signed off against a night sky, invisible by day; approved alone, unreadable in a crowd. → verify in both registers and stacked.

## CHECKLIST
**Before authoring:**
- [ ] The event and the message are named — what fired, what it tells the player. No message → cut.
- [ ] Category and visual language chosen (matches its family: hostile / friendly / ambient / transition).
- [ ] A budget set: particle/spawn/instance ceiling and an overdraw/GPU target.
- [ ] Sim target decided per emitter (GPU vs CPU) with the trade written down.
- [ ] For a new effect *type*: an isolated spike map to prove read + budget + stacking (doctrine 3).

**During authoring:**
- [ ] Reuse a parameterised library system where one exists; drive variation via exposed parameters, not a forked asset.
- [ ] Cheapest renderer that reads; translucency/overdraw controlled; FX lights budgeted or replaced with emissive; cheap FX materials.
- [ ] LODs by distance; significance cap; off-screen/distance culling; graceful scalability tiers with the message surviving the low tier.
- [ ] Fires *with* its event, on frame; ability FX via Gameplay Cues on prediction; denial has its own cue; no authoritative state.
- [ ] Profiled: Niagara debugger + `stat GPU`, tested **stacked** in a crowd, not just solo.

**Before recommending done:**
- [ ] Quality bar met; budget confirmed by measurement, not assertion.
- [ ] Reads in both lighting registers; gameplay-critical out-reads ambient.
- [ ] Any engine-behaviour claim (sim modes, collision, scalability API) verified via `engine-verifier`; anything networked paired with `network-engineer`.
- [ ] Judged by a fresh pass — `qa-visual` (reads + runs) and `creative-review` (on-pitch) — never self-run.
- [ ] One-line done recommendation to the Producer — never a self-sign-off.

## Sources
Craft grounded in the standard real-time-VFX and Niagara literature — pin exact figures/API names in the web pass:
- **Epic / Unreal Niagara documentation** — systems/emitters/modules, GPU vs CPU sim, renderers, scalability & significance, the Niagara debugger `[verify — web pass]`.
- **Overdraw and translucency cost** guidance for real-time particles (Epic performance docs, GPU profiling) `[verify — web pass]`.
- **Real-time VFX craft** — the `realtimevfx.com` community body of knowledge on readability, restraint, and effect language `[verify — web pass]`.
- Restraint / "juice has a ceiling" — the Kao et al. juiciness study, **not** duplicated here; it lives in `guides/game-feel.md`.

Engine-behaviour facts (Niagara specifics, GAS cue replication under Iris, the `WITH_EDITOR` perf caveat) belong in `guides/unreal-engine.md` with source citations, not here. Feedback timing and the juice ceiling live in `guides/game-feel.md`; visual-language/contrast theory in `guides/art-direction.md`.
