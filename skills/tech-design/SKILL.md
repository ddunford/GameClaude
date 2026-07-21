---
name: tech-design
description: Produce a committed, fresh-reviewed technical design document for an engineering-heavy feature before its build task starts — problem, approach, data model, interfaces, failure modes, alternatives.
fires-when: Before building any engineering-heavy system whose design is more than a fork — persistence/save schema, netcode/replication design, GAS architecture, a transaction/ledger model, a service API. Not for spatial (level spec) or systems-design (game-design doc) work, and not for a single fork decision (that is decide).
---

# tech-design

**Owner: `technical-director`** (with `backend-engineer` for persistence/economy/fleet and `network-engineer` for replication/authority on their own systems). Spec-first (doctrine 2) protects *spatial* work through the level spec and *systems-design* work through the game-design doc — this is the equivalent committed, reviewed artifact for engineering-heavy features that would otherwise reach code with no design of record. Craft depth lives in the owning guide (`guides/networking.md`, `guides/backend-services.md`); engine facts in `guides/unreal-engine.md`; the `tech/` doc home and write-as-current shape in `guides/design-docs.md`. Link, never restate.

Doctrine this enforces: **spec-first** (2) — the design exists and is committed *before* the build, so a defect is "doesn't match the TDD," not an opinion; **build ≠ verify** (1) — a fresh reviewer, never the author, signs the design off; **traceability** (8) — the build task links back to the committed TDD.

**Distinct from `decide`.** A TDD is a *design* — how a system is built. An ADR (via `decide`) is a *fork* — which of two candidate approaches wins. A decision may precede a design; it does not replace one. If the work is choosing between options, that is `decide`; if it is designing the thing, it is this.

## Procedure

1. **Confirm a TDD is warranted.** Engineering-heavy and design-bearing — a save/account schema, a replication/authority design, a GAS ability architecture, a transaction/ledger model, a service interface. A one-line fork is `decide`; a purely spatial or economy-tuning task is owned elsewhere. If in doubt, a system other code will depend on earns a TDD.
2. **State the problem precisely.** What the system must do, the constraints it runs under, and the roadmap definition-of-done / acceptance criteria it serves — so the design is measured against a target, not a preference.
3. **Verify every engine claim first (doctrine 10).** Any assertion about how UE behaves — Iris, push-model, OnlineSubsystem/EOS, the dedicated-server-target reality — routes to `verify-engine-claim` before it is designed on. Never architect on an unverified assertion.
4. **Write the design artifact** — the committed content, present-tense (doctrine 12):
   - **Problem & constraints** — from step 2.
   - **Approach** — the chosen design and why.
   - **Data model / schema** — versioned and migratable where durable (`guides/backend-services.md`); the long-lead contract downstream systems bind to.
   - **Interfaces** — RPCs / `UFUNCTION`s / service endpoints, with replication conditions and server-authority stated (doctrine 11); each client-reachable endpoint is flagged for `harden-endpoint`.
   - **Failure modes** — what breaks, how it fails safe (a datastore/replication error denies, never grants), idempotency/ordering where it matters.
   - **Alternatives considered** — the main option not taken and its trade-off, so the design is defensible and not re-litigated.
5. **Commit the TDD at `docs/design/tech/<system>-tdd.md` BEFORE the build task starts.** An uncommitted design is not a spec (doctrine 2). This is the `tech/` discipline home (`guides/design-docs.md`).
6. **Fresh review, never the author (doctrine 1).** A different `technical-director` pass or a peer engineer reviews the TDD against the problem and the doctrine rules — MATCH / PARTIAL / MISS on data model, interfaces, authority, failure modes. Only a reviewed TDD opens the build task.
7. **Hand off.** The build task links the committed TDD (doctrine 8); `code-review` and the QA owners later judge the implementation *against it*. A design change during the build edits the TDD in place — never a parallel truth (doctrine 7, 12).

## Block these
- Starting an engineering-heavy build with no committed design of record.
- Substituting an ADR fork decision for a design.
- Designing on an unverified engine assertion.
- The author signing off their own design.
- A durable schema with no version and no migration path.
