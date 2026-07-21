---
name: ingest-asset
description: Measure and validate an acquired or generated asset, curate it into Content/ElseCity/, set collision and budget class, and record provenance — before it is placed or referenced.
fires-when: Before any acquired or generated asset is placed or referenced in a level. Exists because placing from a gitignored vendor path works on one machine and nowhere else, and async-loaded assets report fake bounds.
---

# ingest-asset

**Owner: `tech-artist`.** Measurement/audit tool routing (`GeometryAuditTools`, `ContentAuditTools`) and the ingest capability row: `guides/tooling-ue.md`. Hand the placed result to `qa-visual` — never self-approve placement.

Doctrine this enforces: **build ≠ verify** (1) and **complete or descope** (6).

## Procedure

1. **Measure true geometry before trusting anything.** Use the geometry-truth tools (`GeometryAuditTools`) for real bounds/pivot/scale/forward — async-loaded and packed/instanced assets report *fake* actor bounds. Validate scale, pivot, forward axis, and standard skeleton (for skeletal meshes).
2. **Validate against budget and content standards** — polycount vs the asset's budget class, PBR maps present and correct, texture sizes. Record the budget verdict per asset class.
3. **Curate into the project content root** — copy/retarget into `Content/ElseCity/<Category>/` with the naming convention (`SM_`/`SK_`/`M_`/`MI_`/`T_`). Never place straight from a gitignored vendor path.
4. **Set collision deliberately, per component** where the engine creates bodies server-side with no check — a ninth-floor wall needs none, a ground-floor wall does. Name the cost. For heavy vendor packs, set `NoCollision` in the PLA source level before packing.
5. **Record provenance (mandatory)** — source + licence in the commit message; AI-generated assets keep their prompt.
6. **Decide commit vs declare.** Only content we author or modify moves into `Content/ElseCity/` and is committed. Heavy re-downloadable vendor packs are **declared, not committed** — add to `Tools/required-content.json` (roots, use, sentinel assets) so the startup validator fails loudly on a fresh clone. Never declare a pack that isn't actually placed — it fails the validator forever.
7. **Regenerate the required-content manifest after any placement pass**, or it silently drifts out of date.
8. **Verify references resolve on disk and are self-contained**, then hand to `qa-visual`.
