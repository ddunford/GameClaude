---
name: harden-endpoint
description: Enumerate what a hostile client can send to a client-reachable endpoint; every check names the exploit it prevents; the server stays the sole source of truth.
fires-when: Any Server RPC, client-reachable BlueprintCallable, ability activation, zone/door transition, or anything touching currency, inventory, or position — before it ships.
---

# harden-endpoint

**Owner: `security-reviewer`** (Verify & Judge — finds, does not fix). Authority depth: `guides/networking.md` (replication, server authority, relevancy). Runs cold, never as the engineer who wrote the endpoint: you audit, the engineer fixes, then re-verify with `qa-network`'s negative test.

Doctrine this enforces: **never trust the client** (11) — every client-reachable endpoint is hostile until proven.

## Procedure

1. **Locate the endpoint and its inputs.** Name the file:line, the calling direction (client→server), and every parameter — plus the implicit inputs (caller identity, current server state, timing/order).
2. **Walk it as an attacker.** For each input enumerate the hostile forms: out-of-range, malformed, wrong type, out-of-order, replayed, spoofed-identity, spammed/flooded. Include "reaching the trigger" — arriving at a door or shop is not eligibility.
3. **Map input → exploit → check.** For every hostile input, name the concrete exploit it enables (client-supplied position → teleport/wall-clip; client-supplied price → free purchase; skipped age re-check → minor in a mature zone). A validation with no named exploit is decoration — cut it or name it.
4. **Confirm the server re-derives every decision.** Position, currency, inventory, ability eligibility, zone/age/paid/progression gates are recomputed server-side from server state — never trusted from the payload. `CanActivateAbility` on the server is the source of truth, not the client's activation.
5. **Check rate / ordering / replay.** State transitions are idempotent or sequence-guarded; nothing critical relies on client-side cooldown or ordering.
6. **Treat UGC data as hostile.** Malicious geometry/data is a live surface even though "data not code" — validate budgets, bounds, and referenced assets server-side.
7. **Report findings: severity × file:line × the named exploit × the missing/weak check.** Maintain a carry-forward list for cross-process / gated-zone surfaces. Hand back to the engineer; do not fix it yourself.
8. **Re-verify after the fix** — the exploit must be *observed* to fail via `qa-network`'s negative test, not assumed closed.
