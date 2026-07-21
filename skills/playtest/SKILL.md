---
name: playtest
description: Plan and run a moderated playtest with real target-audience players, observe without leading, and synthesize the sessions into ranked, actionable findings — the qualitative "found the fun" signal the vertical-slice gate needs.
fires-when: Designing or running a playtest, or turning raw sessions into findings — especially to feed the Phase-1 slice gate. Distinct from creative-review (expert judgement) and analytics (telemetry).
---

# playtest

**Owner: `user-researcher`** (Verify & Judge). Craft depth — recruiting/screening, session protocol, non-leading moderation, think-aloud, synthesis into ranked findings — lives in `guides/playtesting.md`; where this sits versus the other judges in `guides/production-pipeline.md`. This is the qualitative *why-and-how-it-felt* signal: **"we found the fun" is a verdict real players return, not an opinion the team holds.** Distinct from `creative-review` (one expert's on-pitch call) and analytics (behavioural *what*, at scale) — you inform the "is it good" gate with evidence, you don't override it.

Doctrine this enforces: **build ≠ verify** (1) — real players, not the team, return the fun verdict; **spec first** (2) — a research question with a defined pass/fail is committed before anyone plays; **the owner's eyes outrank the tool** (9) — observed behaviour outranks what the team hopes.

## Procedure

1. **State the research question first, committed before the session.** "Is the safe→unsafe boundary legible without a prompt?" is a test; "let's watch someone play" is a demo. Define what a pass and a fail look like up front, so the result can't be re-decided to fit what got built.
2. **Match the test type to the question** (`guides/playtesting.md`) — usability, first-time-user/onboarding, fun/engagement, comprehension, or balance. The **fun/engagement** test is the one the slice gate needs: longer, less interrupted, watching for voluntary re-engagement and where attention breaks.
3. **Recruit and screen to the target segment — 6–12 for the slice.** For an all-ages world that means genuine new players, screened, not the team's expert circle; experts hide exactly the new-player confusion that matters. A screener keeps out people who would invalidate the question.
4. **Set up honestly:** consent to record; frame it "we're testing the game, not you — if something's confusing that's our bug." Give **tasks, not a tour** — a goal, and let them find the way.
5. **Moderate without leading.** No explaining, hinting, or rescuing unless the protocol says to — the struggle you'd talk them out of is the finding you came for. Prompt with neutral echoes ("what are you looking at?"), never leading ones. Note the moment you *want* to help: that is a defect location. **Weight what they do over what they say.** Debrief after tasks, not during.
6. **Separate observation from interpretation.** Collect observations verbatim, tagged with player and moment ("P3, 4:10, walked past the exit three times") — that is data; your theory of why is a hypothesis to check, kept apart.
7. **Synthesize into ranked findings** — cluster observations into themes, rank by **frequency × severity**, state each as an **actionable problem, not a fix** ("players can't tell the safe boundary", never "add a fence"; the fix belongs to the discipline and `creative-review`), and evidence each with the behaviour that shows it.
8. **Feed the gate honestly.** The Phase-1 slice gate ("found the fun, and it's feasible") cites your fun/engagement result as evidence, not the team's say-so — report against the experience spec's signal bars. **Be honest to small n:** report severity and frequency, never a fabricated percentage a handful of players can't support. Findings go to the owning discipline and the Directors.
