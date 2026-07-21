# Onboarding — how to run a game with GameClaude

Written for a human. The AI-facing law is `CLAUDE.md`; the deep references are in `guides/`.

## What this is
A game-development **studio, run as a team of agents**. You are the **Director** — the final "is it good / is it sound / will it ship" call is always yours. The agents do the disciplines and, crucially, **check each other**: whoever builds a thing never signs it off.

## The three repos
1. **GameClaude** (this) — the studio. Installs as your game project's `.claude/`.
2. **ue-mcp-toolkit** — the editor toolkit. Into your project's `Plugins/`.
3. **Your game** — the UE5 project that uses both.

## The lifecycle (and where you're pulled in)
0. **Ideation** — decide the game. *(you + creative-director + game-designer)* → **greenlight**
1. **Preproduction** — find the fun: a vertical slice, the metrics, the plan/elevation spec. *(designers + directors)* → **slice approved**
2. **Production** — build to the proven template. *(engineers → artists, run by the producer)* → **alpha**
3. **Content-lock** → **beta** · 4. **Ship** → **gold** · 5. **Live**

A **spike lane** runs alongside every phase: prove risky things in isolation, review, then integrate.

## How you actually work
- Say what you want. The **producer** decomposes it into a gated plan, dispatches each task to the right agent, and keeps one "you are here".
- Builders build; **QA** (is it broken?) and **creative-review** (is it good?) gate it — as fresh passes, never the builder.
- You hold the gates: greenlight, slice, alpha/beta/gold, and any call that costs money, touches the public surface, or is irreversible.

## Start here
`CLAUDE.md` (the law) → `ROSTER.md` (the team) → `guides/tooling-ue.md` (driving Unreal) → `guides/level-design.md` (how a level is specified and verified).

## First run
Convene **Stage 0**: the concept. Bring the seed of an idea; the studio pressure-tests it into a pitch, pillars, and anti-goals — before a single thing is built.
