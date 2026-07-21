---
name: bootstrap-from-spec
description: The one-time top-level standup — turn a committed spec into the whole game's phase roadmap (0→5) and decompose it: the current milestone to task detail, downstream phases as a living forecast that re-scopes at every gate.
fires-when: Once per project, after greenlight, when the spec is committed and no phase roadmap exists yet — "stand up the plan", "lay out the whole game", "bootstrap the roadmap". Not for a single milestone (that is plan-milestone) and not for re-planning an already-open phase.
---

# bootstrap-from-spec

**Owner: `producer`** (framing with all three Directors). The level *above* `plan-milestone`: that skill decomposes one milestone; this one lays out the whole arc once and then hands each phase to `plan-milestone` and `team-execute` in turn. It runs the FRAME + DECOMPOSE steps (1–2) of `guides/production-pipeline.md` Part 1 across every phase at once, then stops. Output: the committed `plan/` roadmap plus the current milestone's phase file.

Doctrine this enforces: **spec-first** (2) — the roadmap is drawn from a committed spec, never invented; **traceability** (8) — every current-milestone task carries an owner + acceptance + a verification link; **complete-or-descope** (6) — downstream is an honest forecast, never a silent promise.

## The one discipline that makes full-up-front decomposition safe

Decomposing all six phases up front is only safe because of the **re-scope-at-each-gate rule** (the SOP close stage, `guides/production-pipeline.md`): every phase-close triggers a mandatory re-scope review of all remaining phases — carry forward / rescope / drop, rewritten as current. So the plan is split by confidence, not treated as one flat commitment:

- the **current milestone** is decomposed to task-level detail — owners + acceptance + a named test-plan, via `plan-milestone`;
- **downstream phases** are a **living forecast** — best-current-understanding tasks, each block explicitly flagged *forecast, not committed*, and never treated as locked truth. A later phase's reality is *expected* to reshape an earlier assumption. This is a forecast that re-scopes at every gate, not a waterfall.

## Procedure

1. **Read the spec and the SOP.** The committed spec (vision, pillars, anti-goals, the ranked emotional beats, city-design, the decisions-log, and the per-milestone definitions of done in `roadmap.md`) + `guides/production-pipeline.md` (the six phases and their gates, §3.2 per-phase deliverable checklists = the per-gate DoD, §3.5 the activation schedule) + `ROSTER.md`. Do not invent a roadmap the spec does not support — where the spec is silent, that is an owner-reserved gap to surface, not to fill.
2. **Lay out the whole phase roadmap, 0→5.** Every phase with its gate and its definition-of-done, drawn from the SOP §3.2 checklists (link them; do not restate). State the whole arc — understand how the game *finishes* as much as how it starts, so the endgame constrains the early calls rather than surprising them later. Mark the phase the project is actually in.
3. **Decompose the current milestone to task detail — via `plan-milestone`.** Owners from `ROSTER.md`, acceptance criteria, and a named test-plan (or `[no-test: <reason>]`) on every task; build≠verify (doctrine 1), so any visual / networked / client-reachable task names a *separate* verify and judge owner. Order by dependency and mark editor-mutating tasks — they serialize; only read-only owners parallelize (`guides/tooling-ue.md`).
4. **Forecast the downstream phases as a living forecast.** Best-current tasks per phase, each block flagged **FORECAST — not committed**, each honouring the activation schedule (§3.5) so long-lead disciplines (backend, moderation/trust-&-safety, character→animation) appear in the phase their architecture must *start*, not the phase they peak. Every downstream phase carries the re-scope-at-gate note verbatim.
5. **Hand off.** Commit the roadmap + the current phase file, each with a **Current state** ("you are here") line, and seed `TODO.md` as the live between-milestone driver. `team-execute` picks up phases in order through the gates; `plan-milestone` re-runs on the next milestone as it opens; the phase-close re-scope review (SOP close stage) rewrites the forecast at each gate. Then stop — this skill runs once.

## What it produces

- `plan/game-roadmap.md` — the whole arc: phases 0→5, each with gate + DoD; the current phase OPEN and pointing at its phase file; downstream phases as living forecasts, each carrying its re-scope-at-gate note.
- `plan/<current-milestone>.md` — the current milestone decomposed to tasks (via `plan-milestone`).
- `plan/STATE.md` — the single "you are here", pointing at both.
