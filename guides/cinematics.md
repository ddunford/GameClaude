# Guide — Cinematics method (Sequencer)

> Read before authoring any cutscene, camera move, or in-engine cinematic. The core idea: **a cinematic exists to land a beat the player can't be trusted to compose for themselves — a reveal, an introduction, a transition — and it earns its interruption of play only when it is short, skippable, and better than what the player would have seen anyway.** It is done only when it reads at the target framerate, holds continuity, respects player agency, and a fresh reviewer judges it on-pitch.

## This role owns ~280 unowned Sequencer tools
The `Sequencer` MCP toolset (~280 tools) is a large, capable, and currently **unowned** surface. This discipline owns it: shots, tracks, keyframes, camera cuts, bindings, and the whole timeline authoring API. The toolset is the *how*; this guide is *what good looks like* and *when a cinematic should exist at all*. Confirm each tool via `list_toolsets`/`describe_toolset` before relying on it (`guides/tooling-ue.md`) — the surface is large and Epic's docs run ahead of what ships. `[verify — web pass: confirm the registered Sequencer toolset name(s) and the high-leverage tools — shot/track/keyframe/camera-cut/binding creation — in the current build]`

## The two failures this prevents
1. **The cinematic that steals the game.** A long, unskippable, control-wrested cutscene dropped into a game whose whole pitch is *player agency in a persistent social world*. Every second the camera is not the player's is a second the player didn't choose — in a sandbox that is a tax, not a gift. Cinematics that overstay, can't be skipped, or fire when the player wanted to keep playing do active harm. Short, skippable, and rare is the default; a long authored cutscene needs to justify its existence against the anti-goals.
2. **The cinematic that doesn't ship.** Authored for a hero capture at editor framerate with GI, translucency, and effects that crater the frame the moment it runs on target — or that breaks the instant the world state isn't exactly what the author assumed (a missing actor, a streamed-out cell, a different time-of-day register). A cinematic is real-time content with a performance budget and a robustness contract, not a pre-rendered video.

## PRINCIPLES
- **A cinematic earns its interruption.** Before authoring, name the beat it lands and why the player composing it themselves wouldn't work. A reveal too important to miss, an introduction that sets a tone, a transition that sells a threshold — those earn it. "It would look cool" does not. In a sandbox, the bar is high and the default is *no cinematic*.
- **Skippable, always; short, by default.** Every cinematic is skippable (and the skip is instant and obvious); every cinematic is as short as the beat allows. Player agency is a pillar — a cinematic borrows control and must give it back fast and on the player's terms.
- **Composition is the craft.** A cinematic is *directed* — framing, staging, camera motion, cut rhythm, lens. The composition theory (leading lines, framing, focal points, negative space, the 180° rule, shot grammar) is owned by `guides/art-direction.md`; this role *applies* it in motion and time. A cut is a pacing beat (`guides/level-design.md`: rhythm designed, not emergent).
- **Motivated cameras, like motivated lights.** A camera move traces to intent — it reveals, follows, or emphasises. An unmotivated drift or a move for its own sake reads as noise, the same defect `guides/lighting.md` names for unmotivated light. Prefer the simplest move that serves the beat.
- **Lighting is the cinematographer's other half — but the register is owned.** A cinematic lights for the shot, but it does **not** invent a new lighting register; it *hooks into* the level's committed day/night registers (`guides/lighting.md`) and, where a shot needs more, uses cinematic-only lights authored *with* `lighting-artist`, motivated and restrained, that don't leak into gameplay. The two registers have one owner; cinematics borrows, it does not fork.
- **Real-time budget, always.** A cinematic runs in-engine at the target framerate on target hardware. It carries a performance budget like any other content; effects, translucency, and dynamic lights inside a shot are profiled (`guides/vfx.md`, `stat GPU`), not eyeballed at editor framerate.
- **Robust to a live world.** Cinematics run in a persistent, streamed, multiplayer world — not a controlled offline scene. A shot must degrade gracefully when an actor is absent, a cell is streamed out, the time-of-day differs, or another player is in frame. Bind defensively; never assume exact world state.
- **Diegetic-first for a social world.** The most robust "cinematic" in a persistent multiplayer sandbox is often *no camera takeover at all* — an in-world staged moment the player watches from their own camera. Reach for a fully directed cutscene only when the beat truly needs authored framing; prefer letting the world perform in front of the player's own eyes (this also sidesteps the multiplayer question below).

---

## Sequencer architecture — the vocabulary
So routing through the toolset is unambiguous `[verify — web pass: confirm current Sequencer terminology and the LevelSequence/Sequencer distinction in UE 5.x]`:
- **Level Sequence** — the cinematic asset: a timeline of tracks, the unit you author, place, and budget.
- **Shots / Sub-sequences** — a Master Sequence composed of Shot sub-sequences (Cinematic Shot track), each its own Level Sequence — the standard way to structure a multi-shot cutscene so shots are authored and re-timed independently.
- **Tracks & sections** — per-object animation: transform, visibility, material, audio, event, camera-cut. Sections are the clips on a track; keyframes drive values within them.
- **Bindings** — how a track binds to a world actor: **possessable** (binds an actor already in the level) vs **spawnable** (Sequencer spawns and owns the actor for the shot's lifetime). Spawnables are more robust in a streamed/live world — they don't depend on a level actor existing — which matters here.
- **Camera Cut track** — drives which Cine Camera Actor is live per shot; the backbone of multi-shot direction.
- **Cine Camera Actor** — the film-camera model: focal length, aperture, focus distance, sensor/filmback. Author lens language here, not on a plain camera.
- **Event track** — fires gameplay/Blueprint events at keyframes (trigger a sound, a VFX cue, a gameplay state change) — the seam between cinematic and gameplay.

## Cameras & lens language
- **Compose with a Cine Camera**, using focal length and focus for real lens language (depth of field to isolate a subject, focal length to compress or expand space). The theory is `guides/art-direction.md`; here it moves.
- **Cut with rhythm, not convenience.** Cut length is pacing; a run of fast cuts intensifies, a long hold breathes (`guides/level-design.md`: the intensity curve). Hold shots long enough to read; cut before they bore.
- **Respect continuity** — the 180° rule, screen direction, eyelines. A continuity break reads as a mistake even to a viewer who couldn't name it.
- **Camera rigs & motion** — cranes, dollies, follows via camera rigs / rail actors where a hand-keyed path would be noisy `[verify — web pass: current Sequencer camera-rig actors and any built-in path/rig tooling]`.

## Cinematic lighting — hooking the register, not forking it
- **Start from the level's committed register** (`guides/lighting.md`). A cutscene at night uses the night register; it does not invent a third setup that then has to be maintained.
- **Cinematic-only lights, authored with `lighting-artist`**, when a shot needs a key/rim the gameplay register doesn't provide — motivated, restrained, and scoped to the shot so they never leak into playable lighting. Manual exposure, locked per shot; no auto-exposure drift mid-cut.
- **Post-process per shot** (colour grade, DoF, vignette) is legitimate cinematic language — but it is *cinematic*, temporary, and removed when control returns; it never becomes the level's look by accident.

## The multiplayer question — cinematics in a persistent shared world
This is the hard, project-specific problem, and it is **owner-reserved / decide-gated**, not a thing to assume:
- A camera takeover is inherently **client-side and per-player** — one player's cutscene is not another's. In a shared social space, wresting one player's camera while others keep playing around them is jarring and can desync the shared read of a moment.
- **Prefer diegetic, in-world staged moments** that every nearby player sees from their own camera — no takeover, no per-player divergence, and it survives the streamed/replicated world (server-authoritative state drives the staged actors; the *performance* is cosmetic and client-side, `guides/vfx.md` cue-path logic applies).
- Any cinematic that *does* take camera control, gate input, or depend on synchronized state across clients touches replication and authority — pair with `network-engineer` and route the design call through `technical-director`'s `decide` method or the owner. Never trust a cinematic to hold a shared world's state.
- Engine specifics (how Level Sequences replicate, `ALevelSequenceActor`/`ULevelSequencePlayer` net behaviour, Sequencer under Iris) belong in `guides/unreal-engine.md` with citations, verified via `engine-verifier` — **do not assume Sequencer replicates cleanly.** `[verify — web pass: LevelSequenceActor replication behaviour and multiplayer cinematic patterns in UE 5.x]`

## Engine facts live elsewhere
Sequencer's engine mechanics — the LevelSequence asset model, player/actor classes, replication behaviour, the render-movie/MRQ pipeline, Take Recorder, Control Rig integration for character animation (which is `animator`'s surface, `guides/animation.md`) — belong in `guides/unreal-engine.md` with source citations, verified via `engine-verifier`. Do not duplicate them here. Character motion inside a cinematic is authored by `animator`; this role directs the camera, timing, and staging around it.

## Phase activation
Per `guides/production-pipeline.md §3.4/§3.5`, cinematics **activates P2 (build), peaking P3 (content-lock)** — it sits at the tail of the character → animation → cinematics chain, so it is blocked until the character and animation pipeline delivers. Authoring cinematics before there are characters to stage and spaces to stage them in is out of order. The door-transition beat (a *transition* cinematic, possibly diegetic) is the earliest likely need.

## QUALITY BAR
A cinematic is ready to recommend when all of these hold — judged fresh (`qa-visual` for reads-and-runs, `creative-review` for on-pitch), never self-signed:
- **Earns its interruption.** The beat is named; a player couldn't compose it themselves; it's the smallest interruption that lands the beat.
- **Skippable and short.** Instant, obvious skip; length justified by the beat, not indulged.
- **Composed and continuous.** Framing, staging, cut rhythm, and lens serve the beat; continuity (180°, eyelines, screen direction) holds; every camera move is motivated.
- **Lit in-register.** Uses the level's committed day/night register; any cinematic-only lights are motivated, restrained, authored with `lighting-artist`, and don't leak into gameplay; exposure locked per shot.
- **In budget at target framerate.** Profiled on target hardware, not editor framerate; effects/translucency/lights inside shots measured (`stat GPU`).
- **Robust to a live world.** Degrades gracefully when actors are absent, cells stream out, or the register differs; bindings defensive (spawnables where a level actor can't be assumed).
- **Multiplayer-honest.** The camera-takeover / shared-state question is answered explicitly (diegetic preferred); anything replicated or authoritative is paired with `network-engineer` and the design call is owner/`decide`-gated.

## COMMON FAILURE MODES
- **The cutscene that steals the game.** Long, unskippable, control-wrested in an agency-first sandbox. → earn the interruption; skippable and short; prefer diegetic.
- **The cinematic that doesn't ship.** Authored at editor framerate; frame-cliffs on target. → real-time budget; profile on target hardware.
- **The brittle cinematic.** Assumes exact world state; breaks on a missing actor or streamed cell or wrong register. → bind defensively; spawnables; degrade gracefully.
- **Forked lighting register.** A third lighting setup invented for a cutscene, then unmaintained and inconsistent with gameplay. → hook the committed register; cinematic-only lights scoped to the shot, authored with `lighting-artist`.
- **Unmotivated camera.** Drifts and moves for their own sake; noise. → every move traces to intent; simplest move that serves the beat.
- **Continuity breaks.** 180° violated, eyelines wrong, jump cuts. → shot grammar and continuity checked; hold shots long enough to read.
- **Multiplayer-blind.** Assumes a single-player camera in a shared world; desyncs the moment. → answer the shared-world question; pair with `network-engineer`; owner/`decide`-gate the design.

## CHECKLIST
**Before authoring:**
- [ ] The beat is named and the interruption justified against player-agency pillars; a diegetic (no-takeover) option considered first.
- [ ] Shot list / storyboard: framing, staging, cut rhythm, lens language decided before keyframing.
- [ ] Lighting approach agreed with `lighting-artist` — which register, any cinematic-only lights, scoped to shots.
- [ ] A performance budget set for the sequence; character animation dependency (`animator`) confirmed available.
- [ ] The multiplayer question answered — per-player takeover vs diegetic vs replicated — and any authority/replication touch routed to `network-engineer` and owner/`decide`.

**During authoring:**
- [ ] Structured as Master + Shot sub-sequences; camera cuts drive Cine Cameras; bindings defensive (spawnables where the world can't be assumed).
- [ ] Every camera move motivated; continuity (180°, eyelines, screen direction) held; cuts paced to the beat.
- [ ] Exposure locked per shot; cinematic-only lights restrained and non-leaking; post-process scoped to the cinematic.
- [ ] Skip is instant, obvious, and returns control cleanly.
- [ ] Profiled on target hardware; effects/lights inside shots measured, not eyeballed.

**Before recommending done:**
- [ ] Quality bar met; budget confirmed by measurement.
- [ ] Any engine-behaviour claim (Sequencer replication, MRQ, class behaviour) verified via `engine-verifier`; anything networked paired with `network-engineer`.
- [ ] Reads at target framerate in the register it plays in; robustness tested against a missing actor / streamed cell.
- [ ] Judged fresh by `qa-visual` (reads + runs) and `creative-review` (on-pitch) — never self-run.
- [ ] One-line done recommendation to the Producer — never a self-sign-off.

## Sources
Craft grounded in film cinematography and game-cinematics practice — pin exact references in the web pass:
- **Epic / Unreal Sequencer documentation** — Level Sequences, shots/sub-sequences, tracks, bindings (possessable/spawnable), Camera Cut track, Cine Camera Actor, event tracks, MRQ. `[verify — web pass]`
- **Cinematography & shot grammar** — framing, the 180° rule, continuity, lens language, cut rhythm (standard film-craft references). `[verify — web pass]`
- **Game cinematics & player agency** — the practice on when a cutscene earns its interruption and skippability as a baseline. `[verify — web pass]`
- Composition theory lives in `guides/art-direction.md`; lighting registers in `guides/lighting.md`; character motion in `guides/animation.md`; pacing/rhythm in `guides/level-design.md`; VFX cue-path and budget in `guides/vfx.md`. Engine mechanics and Sequencer replication belong in `guides/unreal-engine.md`.
