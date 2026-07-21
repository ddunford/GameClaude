# Guide — Functional QA method

> Read before writing a test plan or filing a defect. The core idea: **a feature is correct when it does what the spec says on *every* path — happy, edge, boundary, invalid, and interacting — proven by a plan written before the build and run by someone who didn't build it.** Functional QA is the gap between "it renders right" (`qa-visual`) and "it's authoritative" (`qa-network`): it asks *does the behaviour match the spec*.

## The failures this prevents
1. **The happy-path pass.** A feature "tested" by doing the one thing it was built to do, in the one order it was built for. Every real bug lives just off that path — the empty inventory, the max stack, the double-click, the two systems firing at once.
2. **The moving target.** No plan committed before the build, so "correct" is decided after the fact to match whatever got built. A defect becomes an argument instead of a spec-line citation.
3. **Silent regression.** A fix or a new feature quietly breaks something that used to work, and nobody re-checked it because "the change was small."

## PRINCIPLES
- **Test-plan first, committed before build** (doctrine 2, 8). The plan is the authority; a defect is "doesn't match the plan," not an opinion. Every task links a plan or declares `[no-test: <reason>]` — no third option.
- **Fresh, never the builder** (doctrine 1). The author's assumptions are exactly the untested cases; a different person breaks them.
- **The edges are the job.** The happy path is the cheapest 10% of the coverage and the least of the bugs. Boundaries, invalid input, and system interactions are where correctness actually lives.
- **A defect is a repro or it is a rumour.** If you can't reproduce it deterministically, you haven't found it yet — keep hunting until you can, then minimise it.
- **Regression is part of every change.** "Done" includes "didn't break what worked." A fix that reopens a closed bug is a failed fix.
- **Automate the repeatable, explore the rest.** Deterministic, high-value cases become automated tests that run every build; the open-ended hunting stays manual.
- **The owner's experience outranks the pass** (doctrine 9). A behaviour the owner hits that the plan missed means the plan is incomplete — extend it; never re-assert green.

## The test plan (this role's committed output)
Written from the spec, committed to `plan/` alongside the phase file, **before** the build:
- **Feature under test + its spec reference** — the authority every case cites.
- **Preconditions** — build, map, state, seed needed to run.
- **Cases** — each a `given → when → then` assertion with an expected result. Grouped by the taxonomy below.
- **Regression set** — the previously-passing behaviours this change could touch.
- **Automated vs manual** — which cases run in the harness, which are explored by hand.

## Edge-case & boundary taxonomy — how to generate cases
Don't list cases ad hoc; derive them systematically so nothing whole is missed.
- **Happy path** — the intended flow, intended order. The baseline, not the test.
- **Boundaries** — min, max, zero, one, empty, full, first, last, one-past. Off-by-one and overflow live here (currency at 0 and at the cap; inventory empty and at max slots).
- **Invalid & malformed input** — out-of-range, wrong type, negative, null/none, garbage. (For anything client-reachable this overlaps `security-reviewer` — coordinate; you cover correctness, they cover exploit.)
- **Order & timing** — out-of-order steps, interrupted flows, cancel mid-action, spam/rapid-repeat, do-it-twice, do-it-during-something-else.
- **State transitions** — every edge in the feature's state machine, including the ones "you'd never do" (open the menu mid-transition, log out mid-trade).
- **System interactions** — the feature colliding with others: two abilities at once, a zone change during an inventory op, a save triggered mid-action. Most functional bugs are here, not inside one system.
- **Persistence round-trip** — save → quit → load → is the state identical? (Coordinate with `qa-network` for server-authoritative state.)
- **Resource & scale** — many entities, long sessions, repeated cycles (leaks, drift, accumulation).

## Repro discipline
A filed defect carries enough to reproduce it on another machine, first try:
- **Exact steps**, minimised to the shortest sequence that still fails — a 3-step repro is worth ten times a 20-step one.
- **Build / version, map, seed, and starting state.**
- **Expected vs actual**, each tied to the spec line.
- **Frequency** — every time / N-in-M / seen once. "Intermittent" is a flag to keep hunting for the trigger, not a final state.

## Bug taxonomy — severity and priority (separate axes)
- **Severity** (how bad the effect): **S1 crash / data-loss / progression-blocker** · **S2 major feature broken, no workaround** · **S3 feature wrong but workaround exists** · **S4 minor / cosmetic-behaviour**.
- **Priority** (how soon to fix): driven by severity × frequency × how many players hit it × where in the phase. An S2 on the core loop outranks an S1 in a corner nobody reaches.
- File each with severity, a priority recommendation, the repro, and the violated spec line. Severity is yours to assign; priority you recommend, the producer sequences.

## QUALITY BAR
A feature is ready to recommend as functionally correct when — verified by a fresh pass, never self-signed:
- **Plan committed before build**, every case tied to a spec line.
- **All taxonomy categories exercised**, not just the happy path — boundaries, invalid input, order/timing, state transitions, system interactions, persistence.
- **Zero open S1/S2** against the plan; S3/S4 triaged and accepted or scheduled.
- **Regression set re-run green** — nothing that worked before is broken.
- **Every defect reproducible** and minimised; automated cases wired into the build harness.
- **No `[no-test]` without a stated, accepted reason.**

## COMMON FAILURE MODES
- **Happy-path-only pass.** → derive cases from the full taxonomy; the intended flow is the baseline, not the test.
- **Plan written after the build.** → commit the plan first; a retro-fitted plan just describes the bugs that shipped.
- **Grading your own feature.** → fresh tester, always (doctrine 1).
- **Unreproducible "bug" filed and forgotten.** → hunt the trigger to a deterministic repro before filing; minimise it.
- **Skipped regression.** → re-run the affected set on every change, however small.
- **Interaction bugs missed.** → test features *colliding*, not only in isolation — that's where the real defects hide.
- **Severity/priority conflated.** → two axes; a low-severity high-frequency bug can outrank a rare crash.

## CHECKLIST
**Before build (plan):**
- [ ] Feature + spec reference identified.
- [ ] Cases derived across the full taxonomy (happy · boundary · invalid · order/timing · state · interaction · persistence · scale).
- [ ] Regression set identified.
- [ ] Automated vs manual split decided; plan committed to `plan/`.

**During test:**
- [ ] Every case run against the *saved/built* state, fresh (not the builder).
- [ ] Each defect reproduced deterministically and minimised.
- [ ] Severity assigned, priority recommended, spec line cited.
- [ ] Regression set re-run.

**Before recommending pass:**
- [ ] Quality bar met; no open S1/S2.
- [ ] Automated cases wired into the build harness.
- [ ] Report handed to the discipline agent and the producer — not self-cleared.
- [ ] Defects re-verified after fix, with the regression set re-run.

## Sources
Grounded in standard software- and game-QA practice `[verify — web pass: canonical references — ISTQB test-design techniques (boundary-value analysis, equivalence partitioning, state-transition testing); severity-vs-priority convention]`. Engine-side automation via CQTest / the automation harness (`guides/tooling-ue.md`, `guides/unreal-engine.md`).
