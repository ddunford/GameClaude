# Guide — Build-release & DevOps (CI, cook, package, ship)

> Read before touching the build pipeline, the cook, packaging, or CI. The core idea: **a build is only real when a clean machine that never opened the editor can produce it, and a green pipeline proves the build compiled — not that the game is good.** The pipeline is plumbing for the gated process (`guides/production-pipeline.md`), never a substitute for a verify owner.

## The two failures this prevents
1. **"Works on my machine."** A build that links only because *this* workstation has the right engine, plugins, vendor packs, and hand-set ini state. The whole point of CI is a reproducible build from a clean checkout — if it needs a human's local state, it is not a build, it is a snapshot.
2. **Green means shipped.** Treating a passing pipeline as sign-off. CI proves the code compiled, the cook completed, and the automation tests passed — it says nothing about whether the level reads right or the mechanic feels good. Build ≠ verify (doctrine 1) does not lapse because a robot ran it.

## The dedicated-server reality (this project, today)
- **A dedicated-server target needs a source-built engine.** This is a Launcher/EGS install, so `ElseCityServer` will not link — the server-flavoured libraries are not shipped and no plugin substitutes (`guides/unreal-engine.md §1`). It does not block development: PIE ▸ Play As Client and `UnrealEditor.exe -server` both run a genuine `NM_DedicatedServer` world for **correctness** work. It *does* block at-scale packaged multiplayer and any real perf/bandwidth numbers.
- So the build pipeline has a hard prerequisite before Phase 2 can produce shippable server builds: **stand up a source-built (or Epic dev-container) engine on CI.** This is on the critical path to real multiplayer testing and is the reason this discipline activates at P2 (`guides/production-pipeline.md §3.5`).
- **`Build.bat` for editor/client targets must run with the editor closed** — a running editor holds the binary locks (`guides/unreal-engine.md §1`). CI is naturally editor-free; the trap is only on a developer machine.
- Cook, HLOD build, and lighting build are **not agent/toolset-triggerable** from the editor MCP surface (`guides/unreal-engine.md §2`) — they are commandlet/CI steps, which is exactly why they belong to this discipline and this pipeline.

## PRINCIPLES
- **Reproducible from a clean checkout, or it is not a build.** Every input — engine version, plugins, `.uproject` state, LFS content, vendor-pack acquisition, ini — is declared and fetched by the pipeline, never assumed present. A fresh clone that opens an empty level is a pipeline failure, not a content failure (this is why `Tools/required-content.json` + the startup validator exist).
- **One source of version truth.** A single build/version number stamps the binary, the cooked content, the crash reports, and the analytics events. A bug report you cannot map to an exact build is a bug report you cannot action.
- **Automate the toil, gate the judgement.** CI runs the compile, the cook, the automation tests (CQTest, `guides/unreal-engine.md §6`), the content-audit and dependency-closure checks — the mechanical, repeatable checks. It never renders the verdict a fresh QA/creative owner owns.
- **Fail loud, fail early, fail specific.** A missing pack, an unlinked target, a dangling reference must stop the pipeline with a named list, not degrade silently to a build that looks fine on a machine that happens to have the content.
- **Every artifact is traceable and disposable.** Builds are reproducible outputs, not precious state — vendor packs and cooked output are declared and re-buildable, never committed (`.git` stays small; vendor content is re-claimable from Fab). Provenance for anything authored travels in the commit.
- **The pipeline is code, reviewed like code.** CI config, cook scripts, and packaging steps live in the repo, on a branch, reviewed — never hand-tweaked on a build server where the change is invisible and unreproducible.
- **Release is a decision, not a step.** Producing a build is agent-decidable; *shipping it to the public* is owner-reserved — public surface + irreversible (`guides/production-pipeline.md`). The pipeline makes the candidate; the owner ships it.

## QUALITY BAR
The pipeline is ready to rely on when all hold:
- **Clean-machine reproducible.** A from-scratch checkout on a machine that never ran the editor produces the same build — engine, plugins, content, and config all fetched by the pipeline.
- **Editor, client, and (once the source engine is stood up) server targets build on CI** with real pass/fail, editor-closed.
- **Cook + package completes** to a launchable artifact for each target platform, validated by a smoke-launch, not just a zero exit code.
- **Content integrity gated in CI** — required-content manifest validated, dependency closure measured, dangling references caught, before the build is called good (the audit tools this leans on are `tech-artist`'s, `guides/production-pipeline.md §2`).
- **Automation tests run and pass** — CQTest networked-PIE harness and any functional tests, as a pipeline stage.
- **Versioned and stamped.** Every artifact carries the build/version id that crash reports and analytics can join on.
- **Fails loud.** Every known-silent failure (missing pack, unlinked server target, mis-sectioned cvar) has an explicit pipeline check that stops the build with a named cause.

## COMMON FAILURE MODES
- **Works-on-my-machine.** The build depends on undeclared local state. → declare every input; build from a clean checkout in CI.
- **Committing the vendor closure.** Trying to make the build reproducible by committing gigabytes of re-downloadable packs — blows past the LFS allowance to store free content. → declare it in the manifest, fetch/re-acquire it, validate its presence loudly (`guides/production-pipeline.md §2`).
- **Green-pipeline-means-done.** Treating CI pass as sign-off. → CI is the mechanical gate; the verify/judge owners still run.
- **Silent cook drift.** A cook that "succeeds" but drops content, or a stale PLA re-running construction scripts on the server at load (`guides/unreal-engine.md §5`). → smoke-launch the cooked build; grep server logs for version-mismatch in CI.
- **Chasing the server target on a Launcher engine.** Burning time trying to link `ElseCityServer` against a binary install. → it cannot link; stand up the source-built engine first (`guides/unreal-engine.md §1`).
- **Untraceable builds.** No version stamp, so a crash or a metric cannot be tied to a build. → one version-of-truth, stamped everywhere.
- **Hand-tweaked build server.** A fix applied on the CI box, not in the repo — invisible and unreproducible. → pipeline-as-code, reviewed on a branch.

## CHECKLIST
**Standing up / changing the pipeline:**
- [ ] Every build input declared and fetched by the pipeline (engine, plugins, LFS content, vendor packs, ini).
- [ ] Editor + client targets build editor-closed on CI with real pass/fail.
- [ ] Source-built (or dev-container) engine stood up before server builds are expected (`guides/unreal-engine.md §1`).
- [ ] Content-integrity checks wired as blocking stages (manifest, closure, dangling refs).
- [ ] Version stamped into binary, cooked content, crash reports, analytics.
- [ ] Pipeline config committed and reviewed on a branch — no build-server hand edits.

**Per candidate build:**
- [ ] Clean-checkout reproducible.
- [ ] Cook + package completes and smoke-launches for each target.
- [ ] Automation tests (CQTest + functional) pass as a stage.
- [ ] Content audit clean; no vendor-path leakage, no dangling refs.
- [ ] Build/version id recorded and mapped to the commit.
- [ ] Candidate handed to the verify/judge owners and the release decision framed for the owner — never self-shipped.

## Sources
- Epic — [Setting Up Dedicated Servers](https://dev.epicgames.com/documentation/unreal-engine/setting-up-dedicated-servers-in-unreal-engine); Automation & the cook/package pipeline (BuildCookRun / UAT). `[verify — web pass]`
- Epic — Unreal Automation Tool, `BuildGraph`, and CI integration patterns. `[verify — web pass]`
- Project engine facts (server-build reality, cook/HLOD not agent-triggerable, editor-closed builds, WITH_EDITOR perf caveat) live with their citations in `guides/unreal-engine.md §1–2` — link, never restate.
