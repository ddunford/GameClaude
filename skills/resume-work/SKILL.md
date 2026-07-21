---
name: resume-work
description: Cold-session pickup — read the open plan, roster, constitution, and SOP in a fixed order, then state where things stand and the single next action.
fires-when: Session start, or "where were we / where are we / what's next".
---

# resume-work

**Owner: `producer`.** The cold-start orientation named in the constitution's "Session start". It reconstructs the "you are here" without re-deriving settled facts.

## Read order (fixed)

1. **`TODO.md`** (repo root) — **the live driver**: the "you are here" line and the ordered task queue with each item's current status. This is the primary anchor for where things stand and the next ready task.
2. **The open `plan/<phase>.md`** — the **detail** behind each queue item (owner, acceptance criteria, test-plan, verify/judge owners). The queue points into it.
3. **`.claude/CLAUDE.md`** (the constitution) — the doctrine and the phase gates. Do not re-litigate what it settles.
4. **`ROSTER.md`** — who owns what, and which agents are authored vs stubbed.
5. **`guides/production-pipeline.md`** — the SOP loop, the phase this milestone sits in, and the activation schedule (§3.5) for which disciplines are live now.

## Procedure

1. Read the five sources above in order.
2. **Check the environment** before claiming anything is runnable — is the editor up and is the MCP/Remote Control surface reachable (`guides/tooling-ue.md`)? A plan that assumes the editor is live is wrong if it isn't.
3. **Reconcile the "you are here" line against reality.** If `TODO.md`'s current-state line disagrees with its own task markers or the git state, the line is stale — correct it first (a stale line is the worst bug).
4. **State where things stand, in six lines or fewer:** the milestone and its phase · the last completed task · what is in progress (`[~]`) and its verify state · what is blocked (`[!]`) and on what · any owner gate waiting · the single next ready task.
5. **Name the next action and its owner** — the one thing to do next, and who does it. Hand to `team-execute` to run it.

## Do not
- Re-derive settled facts or re-open decisions the constitution or `decisions-log.md` closed.
- Declare the next action before the environment check and the staleness reconcile — a confident next step built on a stale line wastes the session.
