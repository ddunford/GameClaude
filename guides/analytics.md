# Guide — Analytics & telemetry (instrument, measure, inform)

> Read before instrumenting an event, building a metric, or making a "the data says" claim. The core idea: **instrument before you need the answer — a question you did not instrument for is unanswerable after the fact — and the data informs a decision, it does not make it.** Retrofitting events post-launch means launch itself is unmeasured (`guides/production-pipeline.md §3.5`).

## The two failures this prevents
1. **Unmeasured launch.** Telemetry treated as a post-launch add-on, so the moment the studio most needs data — the first players, the first economy, the first retention curve — there is nothing recorded. Analytics activates in **Phase 2** precisely so the instrumentation exists before the data matters.
2. **Numbers as verdict.** A metric quoted as the decision instead of an input to it — "engagement went up, ship it" — with no hypothesis, no confounder check, and no owner. Data narrows a choice; it never overrides the creative vision (`creative-review`) or an owner-reserved call. This is the complement to, not a replacement for, user-research synthesis: analytics tells you *what* players did at scale; user research tells you *why*.

## What this discipline is, and is not
- **Is:** the event/telemetry instrumentation, the metric definitions, the dashboards, and the playtest/live signal that turns behaviour into a legible number — the *quantitative, at-scale* channel.
- **Is not:** playtesting/user-research synthesis (the *qualitative why* — a separate discipline), nor moderation/trust-&-safety (which consumes some of the same signal for a different purpose). Analytics hands its signal to `guides/live-ops.md` (post-deploy watch), to `game-designer` (economy/progression tuning), and to the owner (data-informed calls).

## Instrumentation — get it right at the source or the dashboard lies
- **Define the event before you emit it.** A named event with a versioned schema (name, properties, types, units) and a documented meaning. An event nobody can interpret six months later is noise. One event, one meaning — the docs-as-current rule applies to the event catalogue too.
- **Stamp every event with the build/version** (`guides/build-release.md`) so a metric shift can be tied to the change that caused it, and a live regression to the deploy that introduced it (`guides/live-ops.md`).
- **Server-authoritative events for anything that matters — never trust the client.** Economy, currency, inventory, progression, ability outcomes: the *authoritative* number is the server's, so the metric of record is emitted server-side. A client-sourced economy metric is as forgeable as a client-sourced economy *transaction* (doctrine 11) — fine for funnel/UX telemetry (what the client did in its UI), never as the source of truth for money or balance. Flag which events are trusted vs client-reported.
- **Instrument the question, not everything.** Log against a hypothesis or a decision you will actually make; unbounded "log it all" produces cost, PII risk, and dashboards nobody reads. Every event earns its place by a question it answers.
- **Privacy and consent are owner-reserved.** What personal data is collected, retained, and how — especially all-ages and mature-zone gating — is a legal/compliance surface, not an agent call. Instrument for behaviour, default to aggregate/anonymous, and escalate any PII collection. Never widen collection silently.

## Metrics & dashboards
- **Every metric has an owner, a definition, and a decision it serves.** "DAU", "retention D1/D7/D30", "session length", "conversion", "economy sources/sinks" — each defined precisely (a metric two people compute differently is two metrics) and tied to who acts on it.
- **Baselines before deltas.** A number is meaningless without its baseline and its expected range; a dashboard's job is to make "normal vs abnormal" obvious at a glance, which is what makes it a live-ops watch tool (`guides/live-ops.md`).
- **Guardrail metrics, not just goal metrics.** Watch the thing you might break, not only the thing you want to improve — retention *and* crash rate, engagement *and* economy inflation. A change that lifts the goal metric while quietly wrecking a guardrail is a regression.
- **The funnel and the economy are the two ElseCity-critical dashboards** — onboarding funnel (does a new player reach the first "every door leads somewhere else" moment?) and the creator/economy loop (sources vs sinks, so inflation and dead ends are visible before they rot the world). These are the metrics the pillars live or die by.

## PRINCIPLES
- **Instrument ahead of the question.** The event must exist before the answer is needed; retrofitting loses the history.
- **Define before you emit.** Versioned event schema + documented meaning + build stamp, or the data is uninterpretable.
- **Trusted metrics come from the server.** Never source an economy/progression metric of record from the client (doctrine 11); label trust on every event.
- **Log the question, not the world.** Every event earns its place by a decision it informs; unbounded logging is cost + PII risk + noise.
- **Baselines and guardrails, not vanity.** A metric needs its normal range and a guardrail beside it; watch what you might break.
- **Data informs; it does not decide.** It narrows a choice; the creative call is `creative-review`'s and the owner-reserved call is the owner's. Pair the *what* (analytics) with the *why* (user research).
- **Privacy is owner-reserved.** Aggregate/anonymous by default; PII collection escalates to legal.

## QUALITY BAR
- **Instrumented ahead of need** — the events for a P2+ question exist before that phase needs the answer.
- **Every event defined** — versioned schema, units, documented meaning, build-version stamp.
- **Trust labelled** — server-authoritative for economy/progression/outcome metrics; client events marked as client-reported.
- **Metrics owned and defined** — each has a precise definition, a baseline/expected range, a guardrail, and a decision it serves.
- **Dashboards make normal-vs-abnormal obvious** and are usable as a live-ops watch tool.
- **Funnel + economy dashboards exist** and track the pillar-critical loops.
- **Privacy-clean** — aggregate/anonymous by default; any PII collection escalated and signed off.

## COMMON FAILURE MODES
- **Retrofit telemetry.** Instrumenting after launch; the first players are unmeasured. → instrument in P2, ahead of the question.
- **Uninterpretable events.** No schema, no units, no meaning, no version stamp — a number nobody can trust or join to a build. → define before emit; stamp the version.
- **Client-trusted economy metrics.** Sourcing the metric of record from a forgeable client. → server-authoritative for anything that matters; label trust.
- **Log-everything.** Unbounded events → cost, PII exposure, dashboards nobody reads. → instrument the question.
- **Vanity metrics.** Tracking what looks good, not what informs a decision or guards a risk. → owner + definition + guardrail per metric.
- **Numbers as verdict.** "The data says ship it" with no hypothesis, confounder check, or owner. → data informs; creative/owner decides; pair with the qualitative why.
- **Silent privacy creep.** Widening collection without consent/legal review. → aggregate by default; escalate PII.

## CHECKLIST
**Instrumenting (P2+):**
- [ ] Event defined: name, versioned schema, properties, units, documented meaning.
- [ ] Build/version stamped on every event (`guides/build-release.md`).
- [ ] Trust labelled — server-authoritative for economy/progression/outcomes; client events marked client-reported.
- [ ] Justified by a question/decision it informs — not "log it all".
- [ ] Privacy: aggregate/anonymous by default; any PII escalated to legal/owner.

**Metrics & dashboards:**
- [ ] Each metric has an owner, a precise definition, a baseline/range, and a guardrail.
- [ ] Funnel (onboarding → first payoff) and economy (sources vs sinks) dashboards built.
- [ ] Dashboards make normal-vs-abnormal legible for the live-ops watch (`guides/live-ops.md`).

**Informing a decision:**
- [ ] Hypothesis stated; confounders and build-version shifts checked.
- [ ] Paired with qualitative signal (user research) where the *why* matters.
- [ ] Framed as input to the owning decision-maker — never presented as the verdict.

## Sources
- Game analytics practice — event taxonomy, funnel/retention/economy metrics, guardrail metrics, cohort analysis. `[verify — web pass]`
- UE telemetry surface — the Analytics provider interface and event routing. `[verify — web pass]`
- Server-authoritative sourcing follows doctrine 11 (`security-reviewer`); build traceability is `guides/build-release.md`; live-signal consumption is `guides/live-ops.md`. Distinct from qualitative playtesting/user-research synthesis.
