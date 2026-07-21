# Guide — Playtesting & user research method

> Read before designing or running a playtest. The core idea: **"we found the fun" is a verdict real players return, not an opinion the team holds — and you get it by asking a specific question, watching real people without leading them, and synthesizing what you saw into ranked, actionable findings.** This is qualitative *why-and-how-it-felt*, distinct from `creative-review` (expert on-pitch judgement) and analytics (behavioural *what*, at scale).

## The failures this prevents
1. **The demo dressed as a test.** A session with no research question, where the team drives, narrates, and rescues — you learn the player enjoyed watching, and nothing about whether the game works.
2. **Testing on the wrong people.** Only expert or internal players, who already know the genre and the build — so the new-player confusion that actually matters is invisible.
3. **Data that dies as notes.** A pile of session observations nobody turns into a prioritised, actionable finding — the work happened and changed nothing.
4. **Believing what players say over what they do.** Players rationalise, please, and misremember; the behaviour is the truth, the commentary is a lead.

## PRINCIPLES
- **A research question first.** Every test states what it's trying to learn and what a pass/fail looks like *before* anyone plays. "Is the safe→unsafe boundary legible without a prompt?" is a test; "let's watch someone play" is not.
- **Don't lead the player.** No explaining, hinting, or rescuing unless the protocol says to. The struggle you talk them out of is the finding you came for. Silence is your main tool.
- **Behaviour over opinion.** Watch what they do; weight it above what they say. Ask about their experience, never for design solutions — players report problems well and prescribe fixes badly.
- **Recruit the target audience.** Screen for the segment the question is about. For an all-ages world, that means genuine new players, not the team's expert circle.
- **Separate observation from interpretation.** Record what happened as fact; keep your theory of why as a hypothesis to check. Conflating them manufactures false certainty.
- **Synthesize into ranked findings.** Cluster observations into themes; rank by frequency × severity; state each as an *actionable problem*, not a solution.
- **Honest about small n.** A handful of players surfaces most usability problems but proves no statistics — report severity and frequency, never a fabricated percentage.

## Types of test — match the method to the question
- **Usability test** — can they operate it? (find the door, place the prop, read their health). Task-based, think-aloud, moderated.
- **First-time-user / onboarding test** — does a new player get in without a manual? Recruit fresh players; watch the first N minutes cold.
- **Fun / engagement test** — is the loop compelling? Longer, less interrupted; watch for voluntary re-engagement and where attention breaks. This is the one the slice gate needs.
- **Comprehension test** — do they understand what things mean (the boundary, the icon, the state)? Often a short probe, not a full session.
- **Balance / difficulty test** — where do they stall, quit, or steamroll? Overlaps analytics once instrumented.

## Session protocol — running it clean
- **Recruit & screen** to the target segment; a screener keeps out people who invalidate the question (experts for a new-player test, and vice versa).
- **Set up:** consent to record; state that you're testing the game, not them ("there are no wrong answers; if something's confusing that's our bug, not yours").
- **Tasks, not a tour.** Give them a goal and let them find the way. Watch where they hesitate, backtrack, misread, or give up.
- **Think-aloud:** ask them to narrate their thoughts; prompt with neutral echoes ("what are you looking at?"), never leading ones ("did you see the exit up there?").
- **Moderator restraint:** don't fill silence, don't correct, don't demonstrate. Note the moment you *want* to help — that's a defect location.
- **Debrief** after, not during: retrospective questions about their experience once the task is done, so you don't contaminate the play.

## Synthesis — from sessions to findings
Raw notes are not a finding. The pipeline:
1. **Collect observations** verbatim, tagged with the player and the moment ("P3, 4:10, walked past the exit three times").
2. **Cluster into themes** — group observations that point at the same underlying problem.
3. **Rank** by how many players hit it (frequency) × how badly it hurt (severity: blocked / frustrated / mild).
4. **State each as an actionable problem, not a fix** — "players can't distinguish the safe boundary" (problem for the team to solve), not "add a fence" (a solution you don't own). The design response belongs to the discipline and `creative-review`.
5. **Evidence each finding** with the behaviour that shows it, so it can't be waved away as opinion.

## Where this sits vs the other judges
- **`creative-review`** is an *expert* judging the build against the pitch and the ranked beats — a single informed verdict. **You** bring *many real players'* lived experience. You inform its "is it good" call with evidence; you don't replace or override it.
- **Analytics/telemetry** (activates Phase 2) is *what* players did across a large N. You are *why* and *how it felt*, from close observation of a few. They answer each other's blind spots — pair them where both exist.
- Findings go to the owning discipline and the Directors; the slice gate (Phase 1) cites your fun/engagement result as evidence, not the team's own say-so.

## QUALITY BAR
A playtest is sound when:
- **It had a stated research question** with a defined pass/fail, committed before the session.
- **Participants matched the target segment**, screened, not convenience-picked.
- **Moderation stayed non-leading** — no rescuing, no hinting, behaviour observed clean.
- **Findings are synthesized, ranked, and actionable** — themed, frequency×severity ordered, each evidenced by observed behaviour, each stated as a problem not a fix.
- **Claims match the sample** — severity/frequency, no false statistics from small n.

## COMMON FAILURE MODES
- **No research question.** → define what you're learning and what pass/fail looks like first.
- **Leading the witness.** → neutral prompts only; note where you wanted to help, don't help.
- **Wrong participants.** → screen for the target segment; new players for new-player questions.
- **Say-over-do.** → weight behaviour above commentary; ask about experience, not solutions.
- **Notes, not findings.** → cluster → rank → actionable-problem, each evidenced.
- **False precision.** → report frequency/severity, never a statistic a handful of players can't support.
- **Prescribing fixes.** → surface the problem; the fix belongs to the discipline and `creative-review`.

## CHECKLIST
**Before the session:**
- [ ] Research question and pass/fail defined and committed.
- [ ] Test type matched to the question.
- [ ] Participants screened to the target segment; consent/recording arranged.
- [ ] Tasks written as goals, not tours; think-aloud prompts prepared (neutral).

**During:**
- [ ] "Testing the game, not you" framing given.
- [ ] Moderator stays non-leading; hesitations/backtracks/give-ups noted with timestamps.
- [ ] Debrief held after tasks, not during.

**After:**
- [ ] Observations collected verbatim and tagged.
- [ ] Clustered into themes; ranked by frequency × severity.
- [ ] Each finding stated as an actionable problem, evidenced by behaviour.
- [ ] Report to the discipline + Directors; claims honest to the sample size.

## Sources
Grounded in standard games-user-research and usability practice `[verify — web pass: canonical references — Games User Research (Drachen/Mirza-Babaei/Nacke); Nielsen's usability-testing method and the "~5 users find ~85% of problems" figure and its limits; think-aloud protocol; Steve Krug, Rocket Surgery Made Easy]`.
