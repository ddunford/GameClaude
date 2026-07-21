# GameClaude

**A game-development studio, run as a team of agents** — a reusable operating system for building games with Claude. It takes a proven web-dev `.claude` framework's process rigour, staffs it with a **real game-studio team**, and wires it to **Unreal Engine 5**.

The founding principle, learned the hard way: **whoever builds a thing never signs it off.** Build and verify are different owners; a tool returning success proves the tool ran, not that the work is right.

## The four primitives
- **Agents** (`agents/`) — studio roles as personas (Director, Producer, Level Designer, Tech Artist, QA…). "Who owns this?"
- **Skills** (`skills/`) — process checklists. "How do I run this?"
- **Modules** (`modules/`) — reusable game-system contracts (a door, an ability, save/persistence). "Build this system."
- **Guides** (`guides/`) — deep references the others link to. "Understand this domain."

Plus **hooks** (`hooks/`, guards + context + progress) and **orchestration** (`skills/team-execute` + autopilot).

Start with **`CLAUDE.md`** (the constitution), **`ROSTER.md`** (the team), and **`guides/tooling-ue.md`** (how to drive the editor).

## How it's packaged — three repos
1. **GameClaude** (this) — the workflow. Installs as a game project's `.claude/`.
2. **`ue-mcp-toolkit`** — our reusable Unreal automation (geometry/content audit + capture + PIE test harness + blockout + Remote-Control config + the Fab/asset browser control). Drops into the game project's `Plugins/`. Extends Epic's in-engine MCP; does not fork it.
3. **The game** — the actual UE5 title. Consumes both.

## Install (into a game project)
```
# in the game repo root:
git clone <GameClaude-url> .claude
# then install ue-mcp-toolkit into Plugins/ and enable Epic's
# ModelContextProtocol + AllToolsets + RemoteControl (see guides/tooling-ue.md)
```

## Status — scaffold in progress
✅ Constitution (`CLAUDE.md`) · tool-routing + full-editor-access guide · level-design method · agent template · roster · flagship agent (`level-designer`).
Next: author the priority agents (`producer`, `director`, `game-designer`, `tech-artist`, `tools-programmer`) and the Verify & Judge layer; port the proven trial-1 disciplines; spin out `ue-mcp-toolkit`. See `ROSTER.md` for the full build order.

---
© 2026 Munero Limited.
