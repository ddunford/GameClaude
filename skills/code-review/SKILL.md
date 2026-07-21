---
name: code-review
description: Judge a C++/systems change for architecture, maintainability, convention, and the doctrine rules — the fresh engineering is-it-sound gate, run by a reviewer who is never the author.
fires-when: Any non-trivial C++ or systems change before it merges — a new class, an ability, a replicated system, a service, a refactor of core code. The engineering equivalent of creative-review for art. Skip a pure content/config change with no code surface.
---

# code-review

**Owner: `technical-director` or a peer engineer** — never the author (doctrine 1). Behavioural QA already exists — `qa-functional` asks *does it work*, `qa-network` asks *is it authoritative across server + 2 clients*, `security-reviewer` asks *can a hostile client break it*. None of them asks *is it sound* — architecture, maintainability, convention. This is that gate, analogous to `creative-review` for art: the fresh judge of engineering quality nobody else owns. Engine facts and the module/code conventions live in `guides/unreal-engine.md`; the authority rules in `guides/networking.md`. Link, never restate.

Doctrine this enforces: **build ≠ verify** (1) — a fresh reviewer, never the author; **replace, don't accumulate** (7) — no parallel versions, no dead code; **never trust the client** (11) and **verify claims against source** (10) as review criteria.

## Procedure

1. **Run fresh, never the author (doctrine 1).** The engineer who wrote it is the worst judge of whether it is sound. You review; you do not rewrite — findings go back to the author.
2. **Review against the committed TDD (`tech-design`) where one exists.** Does the implementation match its design of record? A deviation is either a defect or a design change that must edit the TDD in place (doctrine 12) — never a silent divergence.
3. **Architecture & layering.** The change sits in the right layer and honours the seams — replication/authority (`network-engineer`) vs durable/transactional state (`backend-engineer`) vs economy tuning (`game-designer`). No leaky abstraction, no god-class, testable in isolation.
4. **Doctrine rules as review criteria.** Server-authoritative by default (11) — every client-reachable endpoint recomputes its decision server-side and has been through `harden-endpoint`; replication conditions and `GetLifetimeReplicatedProps` are correct and stated; `UPROPERTY`/`UFUNCTION` specifiers are right; C++ for core systems, Blueprint for content/tuning per convention.
5. **Replace, don't accumulate (doctrine 7).** The new implementation deletes the old in the same change — no parallel versions, no commented-out blocks, no dead code, no "temporary" second path left behind.
6. **Convention & engine claims.** Naming and module placement follow the project conventions (`AElseCity…`, module layout); any assertion about engine behaviour baked into the code routes to `verify-engine-claim` before it is trusted (doctrine 10).
7. **Report by severity with `file:line`.** Each finding is architecture / maintainability / convention / doctrine, with the fix's owner being the author. Distinct from `security-reviewer` (names exploits) and the QA owners (behaviour) — you own *is it sound*, not *is it broken*. Re-review after the fix; a clean pass is the merge gate.

## Block these
- Reviewing code you authored.
- Passing a change that leaves a parallel version or dead code behind (doctrine 7).
- Accepting an engine assertion in code without a source citation.
- Merging an implementation that silently diverges from its committed TDD.
- Folding this into behavioural QA — is-it-sound and is-it-broken are different owners.
