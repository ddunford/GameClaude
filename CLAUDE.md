# GameClaude — the constitution

**A game-development studio, run as a team of agents.** This file is the AI-facing law loaded every session: how the studio works and the rules no role may break. It is deliberately short. Detail lives in `guides/`; roles live in `agents/`; procedures live in `skills/`; reusable systems live in `modules/`.

GameClaude is engine-generic in principle and **Unreal Engine 5 in practice**. It installs into a game project as that project's `.claude/`. It expects the companion **`ue-mcp-toolkit`** plugin in the project's `Plugins/` (see `guides/tooling-ue.md`).

---

## The four primitives

| Primitive | Question it answers | Lives in |
|---|---|---|
| **Agents** | "Who owns this?" — a studio role as a persona, with its guides/skills/modules preloaded | `agents/` |
| **Skills** | "How do I run this process?" — a checklist; guides the work, output varies | `skills/` |
| **Modules** | "Build this system" — a contract; same config in, same result out | `modules/` |
| **Guides** | "Understand this domain" — the deep reference the others link to instead of duplicating | `guides/` |

**Hooks** (`hooks/`) enforce guards, inject context, and surface progress. **Orchestration** (`skills/team-execute` + the autopilot) drives a phase to done through the gates.

One fact, one home. Link to it; never duplicate it.

---

## The doctrine — non-negotiable, every role, every time

1. **Build ≠ verify.** Whoever builds a thing never signs it off. QA asks *is it broken*; a **fresh** reviewer asks *is it good*; they are different owners. This is the rule that decides quality — it is violated by convenience and it is the reason trial-1 failed.
2. **Spec first, as a committed artifact.** Plan, metrics, and the canonical-view design exist and are committed *before* the build. A defect is then "doesn't match the spec," not an opinion.
3. **Spike before you integrate.** Prove a mechanic or an area in an **isolated** throwaway map, get it reviewed, then pull it into the main build — or discard it. The main map is never touched by unproven work.
4. **Multi-view or it isn't verified.** Top-down + straight-on elevation + eye-level walk + silhouette, re-shot identically each pass. A cherry-picked hero angle is not QA.
5. **Solid massing; walk, don't fly.** Blockout is volumetric at metric scale, never flat cards. Validate with full gravity and collision, never the editor fly-cam.
6. **Complete or descope.** No placeholders, no silent scope cuts. `[x]` means built, saved, and *verified* — never a hopeful tick. Too big → split or ask.
7. **Replace, don't accumulate.** A new implementation deletes the old in the same commit. No parallel versions, no dead code.
8. **Traceability.** Every task links a verification or declares `[no-test: <reason>]`. No third option.
9. **The owner's eyes outrank the tool.** When the owner sees a defect an automated check missed, the check is what's wrong — audit what it measures; never re-assert the green result.
10. **Verify claims against source.** No assertion about how the engine behaves ships unverified against engine source (`agents/engine-verifier`).
11. **Never trust the client.** Every client-reachable endpoint is hostile until proven; each check names the exploit it prevents (`agents/security-reviewer`).
12. **Docs are written as current.** Every doc reads as if written fresh today. Delete the wrong thing; state the right thing as fact. No changelogs, no "v2", no dated edit notes. Keep a *reason* only where it stops a mistake recurring.
13. **Guides are living — capture the lesson immediately.** The moment you learn something the docs should have told you — an engine quirk, a gotcha, a mistake a discipline should never repeat — write it into the owning guide **in the same session**, as present-tense fact. An engine-behaviour lesson goes in `guides/unreal-engine.md` with a source citation (or `[verify]` until confirmed); a process lesson updates the relevant guide/agent. A lesson that lives only in a session, a commit message, or someone's memory is lost, and the studio repeats the mistake. This is how the knowledge base compounds instead of rotting.

---

## How work flows — the gated pipeline

Lemarchand's phases, each bounded by a gate crossed by a **different owner than the builder**:

```
0 Ideation      → gate: greenlight (owner)
1 Preproduction → gate: vertical slice approved — "we found the fun and it's feasible"
2 Production     → gate: alpha (feature-complete)
3 Content-lock  → gate: beta (content-complete)
4 Ship           → gate: gold
5 Live           → gate: per live change
        ┊
   SPIKE LANE — runs alongside every phase (doctrine 3)
```

Nothing downstream starts until the upstream gate passes. The **Producer** (`agents/producer`) owns *when and in what order*; the **Directors** own *what and whether*; **Verify & Judge** gate work *out*.

The full milestone-execution SOP (decompose → build → verify → review → close), the phase×discipline deliverable map, and the discipline activation schedule live in **`guides/production-pipeline.md`**.

**Decision rights.** *Owner-reserved:* money, public-facing surface, the creative vision, anything irreversible. *Agent-decidable:* reversible, plan-aligned, no spend, no public surface — decide it and log it (`agents/technical-director` via the `decide` method). When unsure, escalate with a recommendation.

---

## The team

The roster lives in `agents/`. Three leadership spines (Creative / Technical / Production) meet in one **Director** (owner-reserved authority); discipline departments hang off them; a builder-independent **Verify & Judge** layer gates everything. Solo, roles are *hats* one owner + the agents wear — but the hats never merge build with verify. See `ROSTER.md`.

---

## Driving Unreal — read this before touching the editor

**`guides/tooling-ue.md` is mandatory reading before any editor work.** It defines, unambiguously, **which tool surface to use for which job**:

- **Unreal's MCP** (Epic's `ModelContextProtocol` + `AllToolsets`: SceneTools, ObjectTools, EditorAppToolset…) — for the standard editor operations Epic already covers well.
- **Remote Control** (`localhost:30010`, `py`/console) — arbitrary game-thread Python and console commands: the long tail Epic's toolsets don't cover.
- **Our toolkit** (`ue-mcp-toolkit`: GeometryAudit, ContentAudit, BrowserToolset + what we build) — the gaps and the *reliable high-level operations* we own (geometry truth, asset/content audit, Fab acquisition, capture, the PIE test harness).

The rule: **Unreal's MCP for what it does well · Remote Control for the long tail · our toolkit for the gaps and anything we need to be reliable and structured.** When a job recurs and the raw route is fiddly, that is a signal to build a toolkit tool for it — we strive for full, first-class editor access and close every gap we hit.

Hard editor rules (full detail in the guide): work on a branch; MCP calls are game-thread and **serial, never parallel**; save, then verify the *saved* state; a tool returning success proves the tool ran, not that the work is right; never `taskkill //IM UnrealEditor.exe`.

---

## Session start

`agents/producer` (resume) reads the open `plan/` phase file, the roster, and this file, then states where things stand and the next action. Do not re-derive settled facts.
