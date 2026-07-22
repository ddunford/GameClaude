---
name: qa-visual-battery
description: Run the fixed multi-view battery on a level — ortho plan + straight-on elevations + eye-level gravity-walk + silhouette, re-shot identically each pass — and report defects against the spec.
fires-when: After ANY change to geometry, materials, lighting, or placement, and always before calling level work done. Runs as a fresh pass, never the builder.
---

# qa-visual-battery

**Owner: `qa-visual`** (Verify & Judge). The battery definition lives in `guides/level-design.md`; the saved-lighting and structural-vs-visual split in `guides/workflow.md`; where this sits in the milestone loop in `guides/production-pipeline.md`. Capture via `CaptureTools` (`guides/tooling-ue.md`). Run cold — never the agent that built the level; a pass with zero findings is a suspicious result.

Doctrine this enforces: **multi-view or it isn't verified** (4), **build ≠ verify** (1), **the owner's eyes outrank the tool** (9).

## Procedure

1. **Check the level is viewable before visual QA.** Visual QA requires a **saved lighting rig in the level**. If the level is unlit, the verdict is "not ready for visual QA — needs a saved lighting register", not a pass and not a fail. A verdict never rests on transient/injected capture lighting — that renders black in a real viewport and nobody else can reproduce it.
2. **Structural checks are an earlier, separate gate** — footprints, seating, collision, walkability on the *unlit* level via geometry-truth tools (`GeometryAuditTools`) and a full-gravity walk. Don't fold them into the visual pass, and don't wait for lighting to run them.
3. **Shoot the fixed battery, re-shot identically each pass** so changes are comparable:
   - **Top-down plan** — orthographic.
   - **Straight-on elevation, one per face** — orthographic (a perspective camera makes foreshortening read as false tilt/rotation).
   - **Eye-level walk** — the human view, at metric eye height.
   - **Silhouette** — reads massing and shape.
   Set **manual exposure + fill** first, or base/corner seating is unverifiable. Record the resolved camera poses so the next pass re-shoots identically.
4. **Fly EVERY position.** Two flattering hero angles standing in for the battery is the exact failure this exists to prevent.
5. **Sweep for floating / interpenetrating geometry** with the geometry tools — do not trust `placed=N` or `get_actor_bounds` on packed/instanced actors; check true base *and* the human elevation view.
6. **Placement audit — the hard rule the AABB sweep alone does NOT satisfy.** An interpenetration sweep that returns pairs and then reasons them away as "intended slop" is the exact failure that shipped a market of stalls overlapping at wonky angles past a green check. So:
   - **Never interpret-away an overlap pair.** Every pair the sweep reports is a defect to *look at*, not dismiss — the burden is to prove it's clean by eye, not to explain it away by category. "Festoon over cart = vertical slop" is only acceptable after a capture confirms it reads clean.
   - **Capture at ALL angles, bright enough to see, and judge every prop RELATIVE to the buildings and to each other** — not just the fixed night-hero poses (night + building occlusion *hide* placement mess; that is how this defect passed). Shoot a **bright** (high-exposure or unlit) **top-down over the building footprints** + **oblique 3/4 views from N/E/S/W** + an **iso** — a placement layer reads instantly against the building masses this way.
   - **Check ROTATION, not just position.** Every prop's yaw must be *intentional* — squared to its aisle/wall, or deliberately angled with reason. Arbitrary/random yaw (a stall skewed 20° for no reason, a cart cross-wise in the lane) is a defect. Bunching on one side, props clipping each other, and overhead strings (festoons/wires) strung at chaotic diagonals instead of coherent runs are all placement defects the top-down + obliques expose.
   - This audit is mandatory after ANY set-dress/placement change, and its output is prop-level: name the actor, the defect (overlap / bad-yaw / bunched / clips-building), and the angle it's seen from.
7. **Evaluate against the committed spec + the block checklist.** A defect is "doesn't match the spec," not an opinion. If the capture set can't answer an acceptance criterion, the verdict is "re-shoot", not a guess.
8. **Report a defect list** — each with the viewpoint it was seen from and a severity. Rendering-only: this proves it *renders* right, not that a player can *walk* it (that's `qa-network`/PIE).
9. **The owner's eyes outrank the query.** If the owner sees a defect a check missed, the check is wrong — audit what it measures; never re-assert the green.
