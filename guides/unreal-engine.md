# Guide — Unreal Engine behaviour (quirks & gotchas)

> **How the engine *behaves*** — the terrain. (How to *drive* it is `guides/tooling-ue.md`; how the *team* works is `guides/workflow.md`.) This guide is **living**: the moment we hit a quirk, we verify it and write it here, same session (doctrine 13).

## The rule for every entry in this guide
Each fact carries a **provenance tag** — no unverified claim is trusted:
- `[SRC: path:line]` — verified against engine source (`engine-verifier`). This is proof.
- `[MEASURED: date]` — observed live in this engine build. Proof for runtime behaviour.
- `[web]` — from documentation / a reputable community source. A **claim**, not proof — carry it, but verify against source before *building on it* (doctrine 10).
- `[verify]` — believed true, not yet confirmed. Resolve before it's load-bearing.

One fact, one home. If a quirk is really about *driving* the editor, it belongs in `tooling-ue.md`, not here.

<!-- Populated by research (archive-mining + web) and by lessons hit during work.
     Sections below are the expected shape; fill each with tagged facts. -->

## Engine version & targets
## World Partition & streaming
## Replication (Iris / networking)
## Collision
## Lighting / rendering (Lumen, Nanite, exposure)
## PIE & dedicated server
## Build / cook / packaging limits
## Assets (bounds, PLA/ISM, import)
## Config (which .ini section, defaults)
