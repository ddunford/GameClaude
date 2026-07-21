---
name: qa-functional
description: Prove a feature behaves correctly against its spec — a test-plan committed before build, then happy path plus every edge, boundary, invalid input, state transition, system interaction, and regression, each defect a minimal repro. Fresh, never the builder.
fires-when: Any mechanic, system, economy rule, progression gate, save/load, or UI logic whose correctness isn't a rendered frame (qa-visual) or a replicated value (qa-network). Runs fresh, never the builder.
---

# qa-functional

**Owner: `qa-functional`** (Verify & Judge — finds, does not fix). Craft depth — the test-plan-first method, the edge-case/boundary taxonomy, repro discipline, and the bug taxonomy — lives in `guides/functional-qa.md`; where this gate sits in the loop in `guides/production-pipeline.md`. This is the gap between `qa-visual` (*does it read right*) and `qa-network` (*is it authoritative*): it asks **does the behaviour match the spec, on every path**. Run cold — never the agent that built the feature; the author's mental model hides the exact assumptions that break.

Doctrine this enforces: **build ≠ verify** (1) — a fresh tester, never the author; **spec first** (2) and **traceability** (8) — a plan committed before build, every case tied to a spec line; **the owner's eyes outrank the tool** (9).

## Procedure

1. **Write the test plan first, committed before the build** (to `plan/` alongside the phase file). Name the feature + its spec reference, the preconditions (build/map/state/seed), and each case as a `given → when → then` assertion. A defect is then "doesn't match the plan," not an opinion. Every task links this plan or declares `[no-test: <reason>]` — no third option.
2. **Derive cases from the full taxonomy, not ad hoc** (`guides/functional-qa.md`): happy path (the baseline, not the test) · boundaries (min/max/zero/one/empty/full/first/last/one-past) · invalid & malformed input · order & timing (out-of-order, interrupted, cancel mid-action, spam, do-it-twice) · state transitions (including the ones "you'd never do") · **system interactions** (two features colliding — where most functional bugs live) · persistence round-trip · resource & scale.
3. **Coordinate the overlaps.** Client-reachable invalid input overlaps `security-reviewer` (you cover correctness, they cover exploit); server-authoritative persistence overlaps `qa-network`. Split the surface, don't duplicate or drop it.
4. **Run every case fresh, against the saved/built state** — never the code you have in your head, never the feature you built.
5. **A defect is a repro or it is a rumour.** Reproduce deterministically, minimise to the shortest sequence that still fails (a 3-step repro beats a 20-step one tenfold), and record build/version, map, seed, starting state, expected vs actual (tied to the spec line), and frequency. "Sometimes breaks" is a flag to keep hunting for the trigger, not a filed bug.
6. **Re-run the regression set** — the previously-passing behaviours this change could touch. "Done" includes "didn't break what worked"; a fix that reopens a closed bug is a failed fix.
7. **File each defect with severity × priority × repro × the violated spec line.** Severity (S1 crash/data-loss/blocker → S4 minor) is yours to assign; priority you recommend and the producer sequences — they are separate axes. Recommend pass only with zero open S1/S2 and S3/S4 triaged.
8. **Find, don't fix** — hand back to the discipline agent; wire the repeatable deterministic cases into the build harness (CQTest / automation, `guides/tooling-ue.md`); re-verify after the fix and re-run the regression set. If the owner hits a behaviour the plan missed, the plan is incomplete — add the case, never re-assert the green (doctrine 9).
