---
name: content-lock
description: The content-lock / freeze discipline for the Phase-3 content-complete gate — what "locked" means operationally, who may break the freeze and how (the exception gate), and the load-bearing author-content-freeze vs. player-UGC-stream distinction.
fires-when: Approaching or holding the Phase-3 (Content-lock) gate — declaring the freeze, ruling on a request to break it, or confirming the game is content-complete for the beta gate.
---

# content-lock

**Owner: `producer`** (with the discipline leads — each department confirms its own content is in and frozen). Runs the Phase-3 **content-lock → beta (content-complete)** gate (`guides/production-pipeline.md` §3.2, Phase 3). After it, no new content enters the build — only fixes.

Doctrine this enforces: **complete or descope** (6) — a lock is only real if everything it covers is built, saved, and verified, never a hopeful tick; **replace, don't accumulate** (7) — a freeze forbids parallel or dead content, not just new content.

## The distinction that makes this skill load-bearing for ElseCity

ElseCity has **two content streams**, and the freeze applies to exactly one of them:

- **Author-content — FROZEN.** Everything the studio builds and ships: districts, doors, the hand-authored destinations, art/lighting/audio passes, cinematics, UI. This is what "content-complete" means and what the lock covers. After lock it is fixed-only.
- **Player-UGC — NOT frozen; it is the product.** The somewhere-elses players build behind every door are a *live stream* by design — the game is a creator economy. A content freeze that tried to lock the UGC stream would freeze the pitch itself.

So the lock freezes the **authored world and its systems**, while the **UGC pipeline stays open** — which is exactly why the *safety envelope* around UGC (`trust-safety` tooling, the whitelisted budget-capped palette, moderation and age-gating) must itself be content-complete and locked *before* beta: the authored guardrails around an unfrozen stream cannot still be in flux. Locking the authored game while its UGC guardrails are unfinished is the failure this distinction exists to prevent.

## What "locked" means operationally

1. **Every authored deliverable for the phase exists, is committed, and is verified** — the Phase-3 checklist (`guides/production-pipeline.md` §3.2) is met, each item signed off by its verify/judge owner, not its builder (doctrine 1).
2. **No new authored content enters the build after the lock** — only defect fixes to content already in.
3. **No parallel or dead content** — a replacement deleted its predecessor in the same commit (doctrine 7); the build carries one version of everything.
4. **The UGC pipeline and its safety envelope are themselves content-complete** — the palette, serialization, moderation/reporting tooling, and age-gating are in and locked, so the open UGC stream runs against frozen guardrails.

## Procedure

1. **Declare the scope of the freeze.** State plainly what is frozen (all author-content + the UGC safety envelope) and what is not (the player-UGC stream). Ambiguity here is where a "small addition" slips the gate.
2. **Confirm content-complete with every discipline lead.** Each department confirms its content is in, committed, and verified against the Phase-3 checklist — producer does not assert it on their behalf. A missing deliverable is "not locked," not an opinion (doctrine 2).
3. **Verify the freeze holds the doctrine-6/7 line.** No placeholders, no silent descopes, no parallel versions. `[x]` means built, saved, and verified.
4. **Stand up the exception gate.** From the lock onward, any change to frozen content is a request, not a commit. Only the producer (with the relevant Director) may approve one, and only under: a ship-blocking defect, a legal/compliance/safety requirement, or an owner-reserved call. Cosmetic or scope-adding "while we're here" changes are refused — that is what the lock is for.
5. **Rule each exception on the record.** An approved break names what changed, why it cleared the bar, and who approved it; it still runs the full verify→judge chain (doctrine 1 does not lapse at lock). Log it so the frozen build has a truthful change trail.
6. **Hand the gate up.** Content-lock → beta is a gate crossed by the Director/owner, not the builder. Producer confirms the freeze is real and complete, then hands it up.

## Block these

- Freezing the authored game while the UGC safety envelope is still in flux — the guardrails around the open stream must be locked too.
- Treating the player-UGC stream as content to be frozen — it is the product, and stays live.
- A "small" content addition waved through without the exception gate — the lock exists precisely to stop this.
- An exception applied straight to the build without its verify→judge pass.
