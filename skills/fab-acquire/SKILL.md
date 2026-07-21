---
name: fab-acquire
description: Search Fab for a FREE asset and Add-to-Project without leaving the editor, by driving the Fab panel's embedded CEF browser via BrowserToolset; verify on disk, then hand off to ingest-asset.
fires-when: An asset (mesh, material, pack) is needed and is not already in the project. Steps are fixed; only the search term changes.
---

# fab-acquire

**Owner: `tech-artist`.** Tool routing and the Fab / `BrowserToolset` specifics: `guides/tooling-ue.md` (the "Acquire assets — Fab (free)" row and the walkable-window rules). Free listings only — anything paid or an unclear licence is surfaced to the owner, never worked around.

Doctrine this enforces: **complete or descope** (6) — never silently fake or work around a missing asset.

## Procedure

1. **Research the exact listing first via Playwright MCP** — confirm the title, that it is genuinely free (`is_free=1`), and the licence terms, before driving the in-editor panel. Guessing the listing wastes an editor round-trip.
2. **Open the Fab panel** in the editor and drive its embedded CEF browser with `BrowserToolset` (`ExecuteJavascript`) — never OS-level input injection (it types into the foreground window). One-time human dependency: the Fab plugin's EOS sign-in (owner action).
3. **Search** for the term; filter to free (`is_free=1`).
4. **Confirm the licence** on the listing matches project use before adding — record the source URL and licence for provenance.
5. **Add to Project.** This imports **in memory only** — it is not yet on disk.
6. **Save, then verify on disk.** Confirm the `.uasset`s exist under `Content/` on disk (a memory-only import works on this machine and nowhere else). A tool returning success proves the click, not the file.
7. **Hand off to `ingest-asset`** from `Content/` onward — measure, curate into `Content/ElseCity/`, set collision + budget class, record provenance. Acquisition alone does not make an asset placeable.
