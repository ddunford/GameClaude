# Guide — Level Design method

> Read before defining or building any level or area. The core idea: **the level is built to match the spec, not the spec reverse-engineered from the level — and it is done only when it reads correctly from plan, elevation, AND eye-level, judged by a fresh reviewer.**

## The two failures this prevents
1. **The flat-card / single-angle trap.** A level that photographs well from one eye-level hero angle and falls apart from every other. Trial-1 built thin facade cards on misaligned masses and self-approved from one street shot; top-down and angled showed a colliding mess.
2. **No authority.** Building with no committed spec, so "wrong" is an opinion and there's nothing to hold the build to.

## Stages — gate to gate
0. **Intent & metrics.** Know what the player *does* here. Lock the **metrics sheet** (below). Optionally a throwaway metric-playground to walk-test scale first.
1. **Paper layout (2D, no engine).** Thumbnails → bubble diagram → top-down plan. Decide the street/space network here, not in 3D.
2. **Blockout (solid massing).** Build the plan as **solid volumetric geometry** at metric scale on a gridded ground — the *whole* area before detailing any part. Walk it with **full gravity + collision**, never fly-cam.
3. **Iterate to a layout freeze.** Expect to delete and rebuild — cheap now, expensive later. Freeze only when it reads and plays. After freeze, changing massing is expensive; art starts only here.
4. **Handoff.** The frozen blockout + the spec artifacts are the authority the art pass (`tech-artist`, `environment-artist`, `lighting-artist`) and QA are held to.

## The committed spec artifacts (this role's outputs)
Committed to the game repo's `plan/` alongside the phase file — so QA and `creative-review` check the build against them:
- **Metrics sheet** — the locked numbers (one page).
- **Top-down plan** — block/space footprints, path widths, node/landmark/door positions on a metric grid.
- **Straight-on elevations** — per key street/space face: heights, roofline rhythm, which frontage is the door/hero.
- **Hero views** — the 2–3 eye-level shots that define the target feel.

## Metrics sheet (UE = centimetres) — starting numbers, tune per game `[verify feel by walking]`
- **Grid:** blockout on a **100 uu (1 m)** grid; kits at 100 uu multiples; snap on.
- **Player:** capsule ~**60 × 176 cm**, **eye height ~152 cm** — build to eye height.
- **Wall** ≥ 20 cm thick, interior ≥ **300 cm** floor-to-ceiling. **Door** 110 × 220 cm. **Passage** ≥ **150 cm** (≥ 2× player width). **Stairs** 15 cm rise / 25 cm run.
- **Camera height + FOV locked early** — they set perceived scale for the whole world.

## Composition — Kevin Lynch, checked per view
Paths · Edges · Districts · Nodes · Landmarks. Each is checked in the view that reveals it: paths in plan + eye-level; **edges** (e.g. a safe→unsafe boundary) in plan + elevation, "visually unmistakable"; districts in plan + silhouette; nodes at eye-level ("does the player see a choice here?"); landmarks in silhouette + from every hero point ("we orient by them, we don't enter them").

## The multi-view verification battery (the "done" gate — run by `qa-visual`, a fresh pass)
Re-shot **identically** every pass so changes are comparable, not cherry-picked:
1. **Top-down (plan)** — matches the approved plan; footprints, widths, no unintended dead-ends; nothing overlapping/colliding.
2. **Straight-on elevation** (per face) — real depth and varied massing (not a flat wall of same-height boxes); everything **seated** (verify with geometry-truth tools, backed by the human eye).
3. **Eye-level walk** — walked with gravity/collision; player fits doors/passages; sightlines terminate on something meaningful; ground-floor has eye-height detail; enclosure varies.
4. **Silhouette** — landmarks read as distinct black shapes against sky; hierarchy holds.

A single flattering angle is not QA. The builder never runs their own gate.
