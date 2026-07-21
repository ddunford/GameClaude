---
name: decide
description: Frame an engineering/scope fork, classify it agent-decidable vs owner-reserved, render an ADR-style verdict, and log the agent-decidable ones to the decisions log.
fires-when: A technical/scope/architecture fork has real options and no obvious answer — plan-milestone flags one, team-execute hits a gate, two approaches compete. Skip creative-direction calls (that is creative-review) and anything already settled in the decisions log.
---

# decide

**Owner: `technical-director`.** The engineering/scope decision method. The complement to `creative-review` (which owns the *creative* call). It decides the agent-decidable and escalates the owner-reserved with a recommendation.

## Procedure

1. **Frame the fork.** State the decision in one line and the real options — each a genuine candidate, not a straw man. If there is only one real option, there is no decision to make.
2. **Verify any engine claim first.** If an option rests on how UE behaves, route it to `verify-engine-claim` before weighing it. Never architect on an unverified assertion (doctrine 10).
3. **Classify with the two-way/one-way-door + decision-rights test.** A fork is **agent-decidable** only if it is *reversible* AND *plan-aligned* AND *no spend* AND *no public surface*. Fail any one → **owner-reserved** (money, the public surface, the creative vision, the irreversible).
4. **Weigh the options** against: the roadmap definition of done, the pillars, settled decisions in `decisions-log.md`, cost, and reversibility. Name the main trade-off of the option you favour.
5. **Render the verdict, ADR-style:** context → decision → rationale → consequences.
6. **Act on the classification:**
   - **Agent-decidable** → decide it, and log the verdict to `decisions-log.md` via `vault-doc-update` (a decisions-log row is an `edit_note` into the table, never an append).
   - **Owner-reserved** → do **not** decide. Hand the framed fork + your recommendation to the Director/owner and stop (`team-execute` holds the gate).
7. **Do not re-litigate a settled decision** without new information — check `decisions-log.md` first.

## Log entry (agent-decidable)

Present-tense, written-as-current (doctrine 12): the decision as it stands now, the date settled, and the rationale. A superseded decision is kept only where its history stops a mistake recurring — as present-tense guidance, not an archived record (`guides/design-docs.md`, "Why not an ADR log").

## Block these
- Deciding an owner-reserved call (money / public / irreversible / vision).
- Building on an unverified engine assertion.
- Re-opening a settled decision with no new information.
