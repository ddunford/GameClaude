---
name: qa-network-harness
description: Set the PIE net-mode CDO, run a dedicated server + N clients via NetworkHarnessTools, assert from all parties, run the negative test, and restore the CDO.
fires-when: Anything touching replication, authority, abilities, persistence, or anything a second player must see. Skip only for changes with no networked surface.
---

# qa-network-harness

**Owner: `qa-network`** (Verify & Judge). PIE CDO / net-mode mechanics and the `NetworkHarnessTools` surface: `guides/tooling-ue.md` (the "Play & test" and "Automated playtest input" rows). Networked design depth: `guides/networking.md`. Run cold; report to the engineer, don't fix.

Doctrine this enforces: **build ≠ verify** (1) — one client can never verify replication.

## Procedure

1. **Begin the session** — `NetworkHarnessTools.begin_session` records the current play-settings CDO, sets net mode, and starts a **dedicated** PIE server + N clients (≥2) in one process. Never a listen server — the host *is* the server and can't test "never trust the client".
2. **The harness is stateful and multi-call** — PIE ticks *between* calls, so drive it across `get_session_state` / `drive_pawn` / `assert_pawn_at` / `assert_pawns_consistent`; one blocking call can't drive it.
3. **Assert from every party** — server, client 1, and client 2. Client 2 is what catches owner-relevancy mistakes the server and client 1 both miss.
4. **Run the negative test** — the exploit/abuse case (from `harden-endpoint`'s findings) must be *observed* to fail, not assumed. This is what closes a security fix.
5. **End the session** — `end_session` restores the CDO. It is global editor state; a leak silently changes every later test. Confirm the restore.
6. **Report** per-party observations + the negative-test result + a structured pass/fail, with the CDO restore confirmed.
