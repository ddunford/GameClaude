---
name: team-execute
description: The producer autopilot — run a planned phase to done, dispatching each task to its owner through the verify→judge gates while keeping the single "you are here" line true.
fires-when: Executing a planned phase — "run Phase N", "team-execute the X pass", "who works on what next". Not for a single obvious one-owner task, and not for planning (that is plan-milestone).
---

# team-execute

**Owner: `producer`.** The autopilot the constitution names — it drives the inner loop (steps 3–7) of `guides/production-pipeline.md` Part 1 across every task in the open `plan/<milestone>.md`.

The one law it exists to enforce: **whoever builds a thing never signs it off** (doctrine 1). Every build→verify arrow crosses to a *different, fresh* agent.

## The serial-vs-parallel rule — read first

The **editor is single-threaded**; MCP calls run on the game thread and deadlock if concurrent (`guides/tooling-ue.md`). So:
- **Serialize every editor-mutating task** — one build agent in the editor at a time.
- **Parallelize only read-only owners** — reviews, audits, research, `verify-engine-claim`, and read-only QA passes on already-saved state.

## Procedure

1. **Load the plan.** Read `plan/<milestone>.md`. Find the next ready task — its dependencies are `[x]` and its inputs exist.
2. **Confirm the task is loop-ready.** It has an owner, acceptance criteria, and a named test-plan (or `[no-test:`). If any is missing, it is not ready — send it back to `plan-milestone`.
3. **Test-plan before build.** Confirm the verifying agent's check is declared. "Done" is fixed before work starts so it can't move to fit the result.
4. **Dispatch the build.** Hand to the owning discipline agent. If it mutates the editor, ensure no other editor-mutating task is running. Mark `[~]` and update the "you are here" line.
5. **Hand off to verify — fresh, never the builder.** Dispatch to `qa-visual` (rendered), `qa-network` (networked), `qa-functional` (systems correctness), `security-reviewer` (client-reachable), `engine-verifier` (engine claim) — as a **fresh subagent**. Read-only verifiers on saved state can run in parallel.
6. **Run the quality gate.** Pass/fail against the committed test-plan — *is it broken / correct / secure?* A defect is "doesn't match the spec," not an opinion. Fail → back to step 4 with the defect list; do not re-assert a green check the owner disputes (doctrine 9).
7. **Run the judge.** For any authored look/feel or creative surface, dispatch `art-director` (look) and/or `creative-review` (on-pitch) as a **fresh subagent** — *is it good / is it ours?* It has standing to say off-pitch, stop.
8. **Mark done only when verified and judged.** `[x]` means built, saved, verified, and judged — never a hopeful tick (doctrine 6). Name the verifier in the status.
9. **Stop at owner gates.** A decision, a purchase, a hand-driven test, an on-pitch reaction, or any owner-reserved call — surface it and stop. Don't guess past it. Route agent-decidable forks to `decide`.
10. **Keep "you are here" true after every dispatch.** The current-state line names the phase, the exact step, what's verified (and by whom), what's blocked (and on what), and the next ready task. A stale line is the worst bug here.
11. **At phase close, run the drain rule.** Every unchecked task gets a home — done / moved to `roadmap.md` / moved to a `TODO` / consciously dropped-with-reason. Capture every lesson into its owning guide **the same session** (doctrine 13). Then hand the phase gate to the Director/owner. "We'll remember" is not one of the options.

## Per-run status output

Phase · exact step · what's verified (name the verifier) · what's blocked (on what) · next ready task · any owner gate hit.

## Block these
- Two editor mutations in parallel (deadlock).
- A verifier or judge that is the same agent as the builder.
- Skipping the verify→judge chain to chain builds.
- Running past an owner gate.
- Letting the "you are here" line rot.
