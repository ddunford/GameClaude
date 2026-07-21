---
name: build-validate
description: Cook and package a target, boot the packaged artifact, smoke-test the critical path, and — for a server build — confirm the dedicated server boots and a client connects; a green editor proves none of this.
fires-when: Before a build is called good — a release candidate, a milestone build, or wiring the build-validation stage into CI. Load-bearing from P2 onward, once a source-built dedicated server exists. A green editor session says nothing about a cooked build.
---

# build-validate

**Owner: `build-engineer`.** A green pipeline proves the build compiled, cooked, and passed its automation — never that the game is good; the verify/judge owners still run (doctrine 1). The cook/package steps, the dedicated-server-build reality, versioning, and content-integrity gates live in `guides/build-release.md`; the engine facts it rests on (a Launcher build cannot link `ElseCityServer`; cook/HLOD/lighting builds are not agent-triggerable; `Build.bat` runs editor-closed) live in `guides/unreal-engine.md §1–2`. Link, never restate.

Doctrine this enforces: **complete or descope** (6) — a smoke-launch of the cooked artifact, never a zero exit code, is what proves the build runs; **build ≠ verify** (1) — this gates the build *out* of the pipeline into QA, it does not sign the game off.

## Procedure

1. **Cook and package the target to a launchable artifact.** Editor-closed, from a clean checkout where possible — a build that needs a human's local state is a snapshot, not a build (`guides/build-release.md`). A cook that "succeeds" while silently dropping content is the failure this catches.
2. **Boot the packaged build.** Launch the cooked artifact itself — compiling and cooking prove nothing about whether the packaged binary starts. A build that won't boot is a fail, however green the pipeline.
3. **Smoke-test the critical path.** The build loads its entry level, no missing content, no version-mismatch in the log, and the one path that must work runs. A smoke test is the minimum real proof, not the full QA battery (that is the verify owners).
4. **For a server build: the dedicated server boots and a client connects.** The packaged server starts a genuine `NM_DedicatedServer` world and a client joins it. This requires a **source-built (or dev-container) engine** — a Launcher build cannot link `ElseCityServer` (`guides/unreal-engine.md §1`). Until that engine is stood up, server correctness runs on PIE-as-client / `UnrealEditor.exe -server`, and this step is deferred, not skipped — the gate is why the discipline activates at P2.
5. **Gate content integrity, loud and specific.** Required-content manifest validated, dependency closure measured, dangling references caught — each failing with a named cause that stops the build, never degrading to something that only looks fine on a machine with the content.
6. **Confirm the version stamp.** The artifact carries the one build/version id that crash reports and analytics join on — an unstamped build is an unactionable bug report waiting to happen.
7. **Hand off; never self-ship.** A passing validation means it cooked and booted — the candidate goes to the verify/judge owners, and the release-to-public decision is framed for the owner (owner-reserved: public surface + irreversible).

## Block these
- Treating a zero exit code, or a green editor, as a validated build.
- Chasing a packaged server target on a Launcher engine.
- A cook that drops content or a build that boots with a version mismatch, passed silently.
- An unstamped or clean-checkout-irreproducible artifact.
- Self-shipping a candidate instead of handing it to the verify/judge owners.
