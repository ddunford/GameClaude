# Guide — How the studio works (the choreography)

> The concrete task-flow. `CLAUDE.md` states the doctrine and the phase gates; this spells out *exactly* how a piece of work moves through the team, so a cold session (or the owner) can see the machine turn.

## The one-line shape
**Owner intent → Producer plans → the right agent builds → a *fresh* agent verifies → a *fresh* agent judges → the gate → the owner.** Build and verify are never the same agent (doctrine 1).

## The flow, step by step

1. **Owner states intent.** "Build the hub street", "add the door mechanic". Not a spec yet — a want.

2. **Producer decomposes it** into `plan/<milestone>.md`. Every task gets, without exception:
   - an **owner** (an agent from `ROSTER.md`),
   - **acceptance criteria** (what "done" means, concretely),
   - a **verification link** — which fresh agent checks it, or `[no-test: <reason>]` (doctrine 8).
   The Producer keeps ONE "you are here" line true at all times.

3. **Design before build (Directors gate).** For anything spatial, `level-designer` writes the committed spec (plan / metrics / elevations / hero views) *before* a primitive is placed. For a system, `game-designer` writes the spec. The relevant Director approves the spec. **No spec, no build** (doctrine 2).

4. **Spike the unknowns first.** If an approach is a guess, build it in an **isolated throwaway map**, get `creative-director` review, then integrate into the main build — or discard (doctrine 3). The main map is never touched by unproven work.

5. **Build — serial on the editor.** The owning build agent (`level-designer`, `gameplay-engineer`, `environment-artist`, `lighting-artist`, `sound-designer`, `network-engineer`, `tech-artist`) does the work, driving the editor per `guides/tooling-ue.md`. **Only one editor-mutating agent runs at a time** — the editor is single-threaded. Save, then work from the saved state.

6. **Verify — fresh, and parallel where read-only.** The builder hands off; it does **not** sign its own work:
   - `qa-visual` — the multi-view battery (top-down / elevation / eye-level / silhouette) for anything rendered.
   - `qa-network` — server + 2 clients + the negative test for anything networked.
   - `security-reviewer` — every client-reachable endpoint; names the exploit each check prevents.
   - `engine-verifier` — any engine-behaviour claim the work rests on.
   These are fresh subagents; read-only ones can run in parallel.

7. **Judge — is it good?** `creative-review` (always a fresh subagent) spec-matches, then scores the ranked beats. It has standing to say *off-pitch, stop*.

8. **The gate.** The Producer assembles the verified + judged result. A phase gate (greenlight / slice / alpha / beta / gold) is crossed by the **Director/owner**, never on the builder's say-so. Owner-reserved calls (money, public surface, vision, irreversible) stop and wait for the owner.

9. **Drain at close.** No task is left homeless: done / moved / consciously dropped-with-reason. Then the milestone is signed off, its record kept as history.

## Who decides what
- **Agent-decidable** (reversible + plan-aligned + no spend + no public surface): `technical-director` decides via the `decide` method and logs it.
- **Owner-reserved** (money, public-facing, the vision, irreversible): framed by the Director, **decided by the owner**. Agents recommend; they never self-approve these.

## A worked example — "add a door that teleports the player"
1. Owner: "a door you walk through to somewhere else."
2. Producer: tasks → [design the mechanic · spike it · build it · harden it · verify it · judge it], each with owner + acceptance + verifier.
3. `game-designer` specs it; `technical-director` confirms the approach is sound (routes the "does Iris separate the two spaces?" claim to `engine-verifier` first).
4. `gameplay-engineer` spikes it in an isolated map → `creative-director` reviews the feel → integrate.
5. `gameplay-engineer` + `network-engineer` build it server-authoritative.
6. `security-reviewer` audits the overlap (what can a hostile client send?); `qa-network` runs server + 2 clients + the negative test; `qa-visual` checks it reads.
7. `creative-review` judges whether the *moment* lands.
8. Producer reports; owner gates.

Every arrow that crosses from "build" to "verify" crosses to a **different agent**. That is the whole game.
