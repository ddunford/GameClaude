# Guide — Driving Unreal Engine

> Read this before any editor work. It defines **which tool surface to use for which job**, the **full-editor-access capability map**, and the **gaps we are closing**. Specific engine-behaviour claims here are marked `[verify]` — confirm against engine source (`agents/engine-verifier`) before relying on them; this framework starts from a clean slate and inherits no unverified "facts".

## The three surfaces — and the one rule

We drive the editor through three surfaces. Naming is deliberate; use the right name so it is always clear what is being called.

| Surface | What it is | Call it | Best for |
|---|---|---|---|
| **Unreal's MCP** | Epic's in-engine `ModelContextProtocol` server + `AllToolsets` (SceneTools, ObjectTools, EditorAppToolset, DataTableTools, Blueprint tools, …) | the MCP client tools (`list_toolsets` / `describe_toolset` / `call_tool`) | Standard editor operations Epic already covers well — placing/querying actors, properties, assets, Blueprints, config. |
| **Remote Control** | Epic's `RemoteControl` plugin, HTTP on `localhost:30010` — runs **arbitrary game-thread Python** and **console commands** | `curl` → `KismetSystemLibrary.ExecuteConsoleCommand` → `py "<script>"` | The long tail: anything no toolset exposes, batch scripts, console commands. The full editor Python API on the game thread. |
| **Our toolkit** (`ue-mcp-toolkit`) | *Our* plugin, registering custom toolsets into Unreal's MCP server. Today: `GeometryAuditTools`, `ContentAuditTools`, `BrowserToolset`. | same MCP client tools | The **gaps** and the **reliable, structured, high-level** operations we own. |

**THE ROUTING RULE:**
> **Unreal's MCP for what it does well · Remote Control for the long tail · our toolkit for the gaps and anything we need reliable and structured.**

And the ambition: **we strive for full, first-class editor access.** When a job recurs and the raw route is fiddly or fragile, that is the signal — the **Tools Programmer** (`agents/tools-programmer`) builds a first-class toolkit tool for it, with a structured return, and this guide's capability map gains a row. Leave no rock unturned; close every gap we hit.

> ⚠️ **We ride Epic's MCP server; we do not fork or replace it.** Epic's plugin ships in-engine (experimental, NoRedist). We *extend* it by registering toolsets via the public `ToolsetRegistry`, and we *configure* it (`.ini`). A standalone server would just re-implement transport Epic gives us free.

---

## The capability map — full editor access, by job

What we can do, which surface does it, and where the gap is. This is the **target state**; rows marked ⧗ are toolkit work not yet built.

| Job | Surface / how | Status |
|---|---|---|
| **Place / move / duplicate / query actors** | Unreal MCP — `SceneTools`, `ObjectTools` | ✅ |
| **Read/write actor & asset properties** | Unreal MCP — `ObjectTools` (public props); Remote Control `py` (anything editable) | ✅ |
| **Read *protected/private* C++ properties** (WP grid, engine internals) | our toolkit — C++ tool (`FindFProperty` bypasses access specifiers) | ⧗ build |
| **Author Blueprints / Materials / DataTables / Niagara / Sequencer** | Unreal MCP — the respective toolsets | ✅ |
| **Arbitrary editor Python (game thread)** | Remote Control → `py "<path>"`; log results, read via logs | ✅ |
| **Console commands / cvars** | Remote Control → `ExecuteConsoleCommand` | ✅ |
| **Geometry truth** — true rendered base, seating, interpenetration (bounds *lie* on PLAs/ISMs `[verify]`) | our toolkit — `GeometryAuditTools.measure_true_base` / `sweep_interpenetration` | ✅ |
| **Content / asset audit** — mesh-path provenance, dependency closure, dangling refs | our toolkit — `ContentAuditTools` | ✅ |
| **Screenshots / views** (top-down, elevation, eye-level, silhouette) | our toolkit — a capture tool wrapping SceneCapture2D/HighResShot. **Requirements** (all smoke-test-earned, `[MEASURED: 2026-07-21]`): prime the cold-start (first render is black — capture ~6×); add sun+sky+skylight if the level has none (empty levels render black); **orthographic projection for plan & elevation** (perspective foreshortening reads as false tilt/rotation to a reviewer); **manual exposure + fill** (blown/crushed frames make seating unverifiable); return the image path; expose the canonical-view battery in one call | ⧗ harden |
| **Design & build levels** | plan/metrics/elevation spec (`agents/level-designer`) → build via Unreal MCP + Remote Control, seated by geometry-truth tools | ✅ (method) |
| **Play & test — PIE / dedicated server + clients** | Unreal MCP `EditorAppToolset.StartPIE` (set the `LevelEditorPlaySettings` CDO for net mode first, restore after); a **test-harness tool**: launch → drive a pawn through the level → multi-view capture → assert → structured pass/fail | ⧗ build harness |
| **Automated playtest input** — walk a route, trigger a door | code-driven pawn control in PIE (pragmatic); true simulated input is fiddly | ⧗ build |
| **Perf capture** — frame/CPU/GPU times | Remote Control `stat` cvars off a PIE/`-server` run → parse | ⧗ tool |
| **Acquire assets — Fab (free)** | our toolkit — `BrowserToolset` drives the Fab panel's embedded browser (`ExecuteJavascript`). Research exact listings first via Playwright MCP | ✅ |
| **Generate assets** — props (Meshy-class), and **sound effects & music** | driven through authenticated web tools via **Playwright MCP** + `.env.services` creds (never printed). Sound/music: ElevenLabs. Ingest → `Content/<Project>/`, wire client-side | ✅ (method) |
| **Ingest assets** — measure, collision, budget class, provenance, curate into the project content root | `agents/tech-artist` (`ingest-asset` method) + `ContentAuditTools` | ✅ |
| **Compile C++** | `LiveCodingToolset.CompileLiveCoding` (function bodies); full `Build.bat` + editor restart for new `UFUNCTION`/`UPROPERTY`/classes | ✅ |
| **Config / project settings** | Unreal MCP `ConfigSettingsToolset`; some pages are `.ini`-only (edit + restart) `[verify]` | ✅ |
| **Cook / package / build lighting / build HLOD** | limited on a Launcher build; needs a source-built engine | ⛔ gap (engine) |

**When you request rather than build:** if an asset (mesh, sound, music) is needed and not acquirable free/automatically, or a capability needs the source-built engine, **surface the request to the owner** — never silently work around it or fake it (doctrine 6).

---

## Hard rules for the editor (operational — `[verify]` the engine specifics)

- **Work on a branch.** Never commit editor-automation output to the game's main branch; never push/merge unless asked.
- **MCP calls run on the game thread — serial, never parallel.** Concurrent calls deadlock. One at a time. Parallelise only *read-only* agents (reviews, audits, research); serialise every editor mutation.
- **Save, then verify the SAVED state.** MCP edits are often not undoable across compilation. A capture or check must read the committed+saved level, not an in-memory hope.
- **A tool returning success proves the tool ran, not that the work is right.** Always verify the result; for anything visual, verify with the multi-view battery and a *fresh* reviewer (doctrine 1, 4).
- **Confirm which editor you're driving** if behaviour contradicts a change you just made — one MCP server per port; a stale editor keeps answering.
- **🚨 Never `taskkill //IM UnrealEditor.exe`** — the `-server` process and the owner's editor share one image name; kill one captured PID, never a name. Shut a `-server` run down from inside (`quit` in its exec list).

---

## Setup the toolkit expects (documented dependency)

The game project must have, in `Plugins/`, the **`ue-mcp-toolkit`** plugin, and in the engine/project, Epic's **`ModelContextProtocol`**, **`AllToolsets`**, and **`RemoteControl`** enabled and configured (auto-start server; RC console-command allowlist). The toolkit repo's own README owns the install steps; this guide owns *how to drive it*.

*One home per fact: engine-behaviour truths live in the specific `guides/` topic or the toolkit's docs, verified — not duplicated here.*
