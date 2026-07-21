---
name: team-execute
description: The producer autopilot — run a planned phase to done, dispatching each task to its owner through the verify→judge gates while keeping the single "you are here" line true.
fires-when: Executing a planned phase — "run Phase N", "team-execute the X pass", "who works on what next". Not for a single obvious one-owner task, and not for planning (that is plan-milestone).
---

# team-execute

**Owner: `producer`.** The autopilot the constitution names — it drives the inner loop (steps 3–7) of `guides/production-pipeline.md` Part 1 across every task in the active phase.

**`TODO.md` (repo root) is the live driver it reads and keeps updated.** It is the flat, ordered, always-current queue of the phase's work with a status marker on every item and a link to that item's detail in `plan/<phase>.md`; it also carries the single "you are here" line. `team-execute` picks the next open TODO item, opens its linked phase-file detail, runs it through the gates, and updates `TODO.md` continuously — ticking done, marking in-progress, adding newly-discovered work. **`TODO.md` owns the queue + status; the phase file owns the detail** (owner, acceptance, test-plan, verify/judge owners). Keep the two in sync; never copy detail down into `TODO.md` (one-fact-one-home).

The one law it exists to enforce: **whoever builds a thing never signs it off** (doctrine 1). Every build→verify arrow crosses to a *different, fresh* agent.

## The serial-vs-parallel rule — read first

The **editor is single-threaded**; MCP calls run on the game thread and deadlock if concurrent (`guides/tooling-ue.md`). So:
- **Serialize every editor-mutating task** — one build agent in the editor at a time.
- **Parallelize only read-only owners** — reviews, audits, research, `verify-engine-claim`, and read-only QA passes on already-saved state.

## Procedure

1. **Read the queue.** Open `TODO.md` — the live driver. The next ready task is the next open item (`[ ]`) whose dependencies are `[x]` and whose inputs exist. Open its linked detail in `plan/<phase>.md`.
2. **Confirm the task is loop-ready.** Its phase-file detail has an owner, acceptance criteria, and a named test-plan (or `[no-test:`). If any is missing, it is not ready — send it back to `plan-milestone`.
3. **Test-plan before build.** Confirm the verifying agent's check is declared. "Done" is fixed before work starts so it can't move to fit the result.
4. **Dispatch the build.** Hand to the owning discipline agent. If it mutates the editor, ensure no other editor-mutating task is running. In `TODO.md`, mark the item `[~]` (with where it got to) and update the "you are here" line.
5. **Hand off to verify — fresh, never the builder.** Dispatch to `qa-visual` (rendered), `qa-network` (networked), `qa-functional` (systems correctness), `security-reviewer` (client-reachable), `engine-verifier` (engine claim), and `perf-gate` (hot-path/perf-sensitive work) — as a **fresh subagent**. From P2 onward a milestone build also runs `build-validate` (cooked build boots, server + client connect). Read-only verifiers on saved state can run in parallel.
6. **Run the quality gate.** Pass/fail against the committed test-plan — *is it broken / correct / secure / within budget?* A defect is "doesn't match the spec," not an opinion. Fail → back to step 4 with the defect list; do not re-assert a green check the owner disputes (doctrine 9).
7. **Run the judge.** For any authored look/feel or creative surface, dispatch `art-director` (look) and/or `creative-review` (on-pitch); for any non-trivial C++/systems change, dispatch `code-review` (is-it-sound engineering) — each as a **fresh subagent, never the author** — *is it good / is it ours / is it sound?* They have standing to say off-pitch, stop. For a Phase-1 slice, the "found the fun" verdict comes from a `playtest` (`user-researcher`), not internal review alone.
8. **Mark done only when verified and judged.** In `TODO.md`, `[x]` means built, saved, verified, and judged — never a hopeful tick (doctrine 6); name the verifier in the status. Keep the phase-file detail in sync if a task splits or its acceptance changes.
9. **Stop at owner gates.** A decision, a purchase, a hand-driven test, an on-pitch reaction, or any owner-reserved call — surface it and stop. Don't guess past it. Route agent-decidable forks to `decide`.
10. **Keep the queue and "you are here" true after every dispatch.** The "you are here" line at the top of `TODO.md` names the phase, the exact step, what's verified (and by whom), what's blocked (and on what), and the next ready task. As work surfaces mid-build — a newly-discovered task, a debt, a follow-up — add it to `TODO.md` so the queue stays complete. A stale line is the worst bug here.
11. **At phase close, run the drain rule, then the two required close sub-steps.** Every open item in `TODO.md` gets a home — done / moved to `game-roadmap.md` / consciously dropped-with-reason; a debt with no phase attachment survives in the `TODO.md` "no other home" section across the gate. Capture every lesson into its owning guide **the same session** (doctrine 13). Then, before sign-off: run **`process-retro`** (produces `plan/<phase>-retro.md` — how the studio *worked* this phase, fed back into the process) and walk **`plan/risk-register.md`** row-by-row as part of the re-scope (retire / carry-forward-and-re-score / newly-surface each row; 🔴 R1/R2/R3 first). For the Phase-3 content-lock gate the freeze is run via **`content-lock`**. Then hand the phase gate to the Director/owner. "We'll remember" is not one of the options.

## Per-run status output

Phase · exact step · what's verified (name the verifier) · what's blocked (on what) · next ready task · any owner gate hit.

## Block these
- Two editor mutations in parallel (deadlock).
- A verifier or judge that is the same agent as the builder.
- Skipping the verify→judge chain to chain builds.
- Running past an owner gate.
- Letting the `TODO.md` queue or its "you are here" line rot, or building from a task not tracked in it.
