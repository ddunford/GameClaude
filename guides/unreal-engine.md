# Guide — Unreal Engine behaviour (quirks & gotchas)

> **How the engine *behaves*** — the terrain. (How to *drive* it is `guides/tooling-ue.md`; how the *team* works is `guides/workflow.md`.) This guide is **living**: the moment we hit a quirk, we verify it and write it here, same session (doctrine 13).

## The rule for every entry
Each fact carries a **provenance tag** — no unverified claim is trusted:
- `[SRC: path:line]` — an engine-source citation exists; checkable any time. Strongest.
- `[MEASURED: date]` — observed live in this engine build. Proof for runtime behaviour.
- `[web]` — from Epic docs / a reputable source (URL). A **claim**, not proof — verify against source before *building on it* (doctrine 10).
- `[verify]` — believed true, not yet confirmed. Resolve before it's load-bearing.

Citations tagged `[SRC:…]` were verified during trial-1; they point at real source lines and are checkable, but a line may have shifted across engine updates — re-confirm if a fact turns load-bearing. The **re-verify queue** at the bottom lists the load-bearing facts a web pass could not independently confirm — `engine-verifier`'s worklist.

---

## 1. Engine version & targets
- Target is **UE 5.8.0**. `[verify]` (project rule)
- **A dedicated-server target needs a source-built engine; a Launcher/EGS binary install cannot link it** — the server-flavoured libs aren't shipped, and no plugin substitutes. `[web]` [Epic — Setting Up Dedicated Servers](https://dev.epicgames.com/documentation/unreal-engine/setting-up-dedicated-servers-in-unreal-engine) · corroborated `[SRC: PlayLevel.cpp:2418]`
- **PIE ▸ Play As Client launches a real in-process dedicated-server world** (`NM_DedicatedServer`) — true server authority for *correctness* without a server target. `[SRC: PlayLevel.cpp:2418]` · `[web]` [Epic — PIE Multiplayer Options](https://dev.epicgames.com/documentation/unreal-engine/play-in-editor-multiplayer-options-in-unreal-engine)
- **`UnrealEditor.exe -server` runs a genuine out-of-process dedicated server** and Iris drives its netdriver. `[MEASURED: 2026-07-19]`
- Both PIE-as-client and `-server` run **`WITH_EDITOR=1`** and leave cooked-server paths untested: valid for authority/replication/relevancy correctness, **invalid for performance numbers** (frame time, bandwidth). `[verify]`
- **`Build.bat` for editor/client targets must run with the editor CLOSED** — a running editor holds the binary locks. `[MEASURED: 2026-07-19]`

## 2. World Partition & streaming
- Server streaming is **opt-in and off by default**: `wp.Runtime.EnableServerStreaming=1` makes the server stream around player sources instead of loading the whole map. Without it the server loads everything (CPU pinned in production). `[web]` [Epic KB — WP Server Streaming](https://forums.unrealengine.com/t/world-partition-server-streaming/688971)
- **`wp.Runtime.EnableServerStreamingOut` stays `0`.** Streaming a cell OUT destroys its actors — on an authoritative server that is data loss. Re-enable only once persistence-on-unload exists. `[SRC: architecture.md §7]` ⚠ **re-verify** (the "streaming-out = actor destruction" causal claim was web-unconfirmed)
- **WP grid cell size + loading range are UI-only in practice** — `UWorldPartition::RuntimeHash` is `protected` and `AWorldSettings::WorldPartition` is `VisibleAnywhere`, so MCP/Python can't set them; it's a World Settings ▸ World Partition Setup action. `[MEASURED: 2026-07-19]` · `[web]` [Epic — World Partition](https://dev.epicgames.com/documentation/en-us/unreal-engine/world-partition-in-unreal-engine)
- Defaults kept consciously: **12800 uu cells / 25600 uu loading range**. Loading range is a radius → doubling it is ~4× loaded set/memory. `[verify]`
- **Changing cell size later re-buckets every actor and forces a full HLOD rebuild.** `[verify]`
- **HLODs are a build step, not automatic** (Build ▸ Build HLODs, or the WP HLODs commandlet) — and not currently triggerable from the agent toolset. `[web]` [Epic — World Partition](https://dev.epicgames.com/documentation/en-us/unreal-engine/world-partition-in-unreal-engine)
- **HLOD layer assets clone from `/Engine/Maps/Templates/HLODs/HLODLayer_Instanced`/`_Merged`; repoint the clone's `parentLayer` at the local copy** or it keeps an engine dependency. A map from the OpenWorld template silently points `default_hlod_layer` at `/Engine/OpenWorldTemplate/HLOD/HLOD0_Instancing` — repoint it. `[MEASURED: 2026-07-19]`

## 3. Replication / Iris
- **Iris status, 5.8:** the plugin metadata still reads Beta (`Iris.uplugin`: `IsBetaVersion:true`, `VersionName:0.1`, `EnabledByDefault:false`) `[SRC: Iris.uplugin]`, while the **5.8 release notes call Iris "production-ready for licensees"** `[web]` [UE 5.8 Release Notes](https://dev.epicgames.com/documentation/unreal-engine/unreal-engine-5-8-release-notes). Net: usable and promoted, but Beta still permits breaking API changes across upgrades — don't claim packaged-build correctness.
- **Enabling Iris is coordinated across four places:** plugin `"Enabled":true` in `.uproject`; `bUseIris=true` in `*.Target.cs` + `SetupIrisSupport(Target)` in `.Build.cs`; cvars `net.Iris.UseIrisReplication=1` **and** `net.SubObjects.DefaultUseSubObjectReplicationList=1`. The cvar alone does nothing; a Blueprint-only project can't enable it (needs the `.Target.cs` edit). `[web]` [Epic — Migrate to Iris](https://dev.epicgames.com/documentation/unreal-engine/migrate-to-iris-in-unreal-engine)
- **`DefaultUseSubObjectReplicationList=1` is mandatory** — the engine asserts without it. `[SRC: EngineReplicationBridge.cpp:234]` · corroborated `[web]` (Migrate to Iris: subobject list is a hard dependency)
- **Every `AActor` is spatially filtered by DEFAULT; do NOT add `FilterConfigs` to "enable" relevancy** — they *override* the default. Add entries only to make a class always-relevant/unrouted. `[SRC: EngineReplicationBridge.cpp:243]` ⚠ **re-verify** (web-unconfirmed; trust the cited line)
- **Spatial separation is plain distance culling** — per-object cull distance (default 150 m 3D); keep zone actors under `MaxNetCullDistance` or they go always-relevant. `[SRC: NetObjectGridFilter.cpp:211,494-500; Actor.cpp:312,101,298]`
- **Live-verified separation at a 2 km offset** (server + 2 clients, Character proxy counts): both at hub = 6; one moved 2 km = 4 (far pawn culled from both other views); both at the offset = 6. `[MEASURED: 2026-07-20]`
- **Iris hard-caps at 128 connections; unchangeable on a Launcher build** — `MaxConnections=128` is a private-header default-arg with no setter/cvar/ini; raising it needs engine source. `[SRC: ReplicationConnections.h:40-45]`
- **Push model is PIE-only on installed builds** (`WITH_PUSH_MODEL=0` in Game/Server targets) — write as if on, don't claim packaged-build push correctness. It's opt-in per property (`DOREPLIFETIME_WITH_PARAMS_FAST` + `MARK_PROPERTY_DIRTY`); miss the mark and it silently reverts to polling. `[SRC: WITH_PUSH_MODEL=0]` · `[web]` (StraySpark, community)
- `LevelStreaming` Level Instance cheap replication path: `COND_InitialOnly`. `[SRC: LevelInstanceActor.cpp:87-95]`
- **Editor `NoRedist` toolsets run Python startup server-side under `-server`**, after the replication system starts → Iris warns `BroadcastLoadedModulesUpdated() called while there are 1 active ReplicationSystems` (risk of corrupt polymorphic data). Disable editor toolsets for `-server` runs. `[MEASURED: 2026-07-19]`

## 4. Collision
- **ISM collision is per-COMPONENT, not per-instance** — all instances share one collision setting, so there's no runtime per-instance toggle. Set `NoCollision` per component in the PLA source level **before packing**. `[web]` [Epic — Instanced Static Mesh Component](https://dev.epicgames.com/documentation/en-us/unreal-engine/instanced-static-mesh-component-in-unreal-engine)
- **A packed kit creates ISM collision bodies on the dedicated server with no server check** — the reason the above must happen pre-pack. `[SRC: architecture.md §7]` ⚠ **re-verify** (web-unconfirmed)
- Measured server cost of one packed block: **1,826 ISM components + 665 BodySetups** (BodySetup is per mesh asset, so it understates per-instance cost). `[MEASURED: 2026-07-19]`
- **UE 5.8 collision channels:** ~6 default object + 2 default trace, plus up to **18 CUSTOM** channels — a hard ceiling to budget. (Trial-1 measured 50 total slots including built-ins; the *custom* budget is 18.) `[web]` [Epic — Add a Custom Object Type](https://dev.epicgames.com/documentation/unreal-engine/add-a-custom-object-type-to-your-project-in-unreal-engine) · `[MEASURED: 2026-07-19]`
- **Channels are integer indices — inserting/reordering silently reassigns every asset that referenced a shifted index.** Reserve append-only. `[verify]`
- **Collision config (`[/Script/Engine.CollisionProfile]`) is hand-edited in `DefaultEngine.ini` and read at startup** (restart to apply). Opening Project Settings ▸ Collision first rewrites the section from in-memory state and wipes the edit; `ConfigSettingsToolset` can't reach it (custom Slate widget). `[MEASURED: 2026-07-19]` ⚠ **re-verify** (rewrite-on-open is project lore)
- **A missing collision profile silently reverts** when set on a component — read-back after setting is the only proof. `[MEASURED: 2026-07-19]`

## 5. Lighting / rendering
- **Sky Atmosphere, Directional Light, Sky Light, height fog, volumetric clouds are scene-global — one active set per world.** Sky Atmosphere supports at most **2 atmospheric directional lights**. `[web]` [Epic — Sky Atmosphere Component](https://dev.epicgames.com/documentation/en-us/unreal-engine/sky-atmosphere-component-in-unreal-engine)
- **A `LevelStreaming` Level Instance streams into the persistent world's ONE `FScene`, so it shares the global day sky** — a Level Instance does NOT grant an independent sky. `[SRC: World.h:1504; SkyAtmosphereRendering.cpp:690-695; RendererScene.cpp:4710-4716; FogRendering.cpp:104]`
- So a night region under a shared day sky is built **spatially**: full enclosure + an **overhead occluder** (an open-top area still sees the global sky and is lit by the global sun) + a **bounded manual-exposure `PostProcessVolume`** + local lights. The occluder must actually seal — if the lid sits above the walls, the day sky leaks the seam and the global sun/skylight still light the interior. `[SRC: architecture.md §7]` · `[MEASURED: 2026-07-20]`
- **Supported baked day/night pattern = Lighting Scenario levels** (one visible at a time; each register's lightmaps bake separately). For a Lumen/dynamic day-night, animate the single shared sun/sky instead. `[web]` [Epic — Precomputed Lighting Scenarios](https://dev.epicgames.com/documentation/unreal-engine/using-precomputed-lighting-scenarios-in-unreal-engine)
- **Use MANUAL exposure, locked per register** — auto-exposure re-balances to whatever's in frame (produced an "olive road cast" from a bright-sky-tuned bias). But **locked ≠ crushed**: exposure locked dark to fake night rendered a fully-planted garden (18 trees + 200+ plants) near-black. Stay visible. The "bias" number is empirical, not EV semantics (11 blew white, 4 read night here). `[MEASURED: 2026-07-19 / 2026-07-20]`
- **Packed Level Actors silently drop lights, Niagara, decals and audio** — door light-spill inside a packed building must be emissive material, not a light (or a separate external WP light actor). `[SRC: architecture.md §7]`
- Baseline is **Lumen + Nanite**. Thin-wall light leak is a Lumen mesh-distance-field resolution problem (thin walls vanish from the SDF). `[verify]`

## 6. PIE & dedicated server
- **Net mode is NOT a `StartPIE` parameter** — the engine reads it from the `ULevelEditorPlaySettings` CDO (`/Script/UnrealEd.Default__LevelEditorPlaySettings`): set `playNetMode` / `playNumberOfClients` / `runUnderOneProcess`, then StartPIE. `[SRC: PlayLevel.cpp:991]`
- **The CDO is global editor state — record prior values, restore after the run.** A leak silently changes every later test's net mode. `[verify]`
- **`runUnderOneProcess` inverts:** ON for agent runs (in-process; the watcher subscribes to `PostPIEStarted`); OFF for manual multi-client testing (more representative). `[verify]`
- **Never use Play As Listen Server for authority work** — the host *is* the server, so it can't test "never trust the client". `[web]` [Epic — PIE Multiplayer Options](https://dev.epicgames.com/documentation/unreal-engine/play-in-editor-multiplayer-options-in-unreal-engine)
- **One client can't verify replication** — client 2 catches owner-relevancy / `bOnlyRelevantToOwner` mistakes. A *single* client under a dedicated-server config can misreport `NM_Standalone`; use ≥1 client with the server explicitly enabled. `[web]` (Epic forum) · `[verify]`
- **Player 2 spawns at world origin (0,0,0) with no 2nd PlayerStart** and falls through thin scaled-cube ground — need proper PlayerStarts + solid ground before a real multiplayer walk. `[MEASURED: 2026-07-20]`
- **CQTest** (`PIENetworkComponent.h`) is a networked-PIE harness defaulting to `bIsDedicatedServer=true`, drivable via `AutomationTestToolset`; needs `"CQTest"` in the module `.Build.cs`. `[SRC: PIENetworkComponent.h]`

## 7. Assets (bounds lie, async-load, import)
- **`get_actor_bounds()` on a Packed Level Actor reports the packed asset's ORIGIN, not the rendered geometry** — it read base `-128` for 27 buildings floating 3.25–12.75 m, and three "floating=0" checks passed on a visibly broken level. Measure true base per-ISM: `true_z = t.translation.z + (mb.origin.z − mb.box_extent.z) * t.scale3d.z`. `[MEASURED: 2026-07-19]`
- **When two measurements of one actor disagree, the contradiction IS the finding** — don't pick the convenient one. `[MEASURED: 2026-07-19]`
- **A suspiciously small bound (~2.6 m) is an async-load artifact, not a small asset** — re-query anything implausible. `[MEASURED: 2026-07-19]`
- **A raw obj/gltf in metres imports 100× oversize in cm** (a fountain at 250 m) — place at scale 0.01 if not baked. Free CC BY "scans" arrive raw/oversized/mis-oriented (a bollard 98k tris/11 m; a shutter 4.2M tris/21 m). `[MEASURED: 2026-07-19 / 2026-07-20]`
- **`Texture2D.max_texture_size` caps RUNTIME resolution only** — the full-res source still sits in the `.uasset` (a "2K-capped" texture was 29 MB on disk). Resize the source to shrink the repo. `[MEASURED: 2026-07-19]`
- **Decimating a scan strips UVs → texture stops mapping.** Enable Nanite on the full mesh instead (preserves UVs, swallows the triangles). `[MEASURED: 2026-07-19]`
- **`AssetTools.duplicate` does NOT rewrite references** — a duplicate still points at the vendor pack. Use Migrate / `migrate_packages` via the Remote Control Python route to curate. `[verify]`

## 8. Config (which section, silent-ignore)
- **Console variables set from ini MUST go in `[SystemSettings]` in `DefaultEngine.ini`** (`[SystemSettingsEditor]` for editor-only). In any other section they are **silently ignored** — no error. The single most common "my cvar has no effect" cause. `[web]` [Epic — Console Variables in C++](https://dev.epicgames.com/documentation/unreal-engine/console-variables-cplusplus-in-unreal-engine) · `[SRC: BaseEngine.ini:2464]`
- Distinct from `Engine/Config/ConsoleVariables.ini`, which has its own `[Startup]` section for early cvars — don't confuse them. `[web]`
- The `[SystemSettings]` block in use: `net.Iris.UseIrisReplication=1`, `net.SubObjects.DefaultUseSubObjectReplicationList=1`, `wp.Runtime.EnableServerStreaming=1`, `wp.Runtime.EnableServerStreamingOut=0`. `[verify]`
- A cvar's `ECVF_` flags say when it can be set — **`ECVF_Runtime_ReadOnly` = startup-only.** `EditorAppToolset.SearchCVars` returns the *live* value (proves config actually took). `[verify]`

---

## Re-verify queue — `engine-verifier`'s worklist
Load-bearing facts a 5.8 web pass could NOT independently confirm; trust the cited line until re-checked against current source, and resolve before building heavily on them:
1. **`EnableServerStreamingOut` → destroys authoritative actors** (`architecture.md §7` — the causal claim).
2. **Iris default spatial filtering / `FilterConfigs` override** (`EngineReplicationBridge.cpp:243`).
3. **ISM collision bodies created on the dedicated server with no server check** (`architecture.md §7`).
4. **Collision-profile ini rewrite-on-open** (project lore).
5. **Iris status label** — reconcile `Iris.uplugin` Beta/0.1 vs the 5.8 release-notes "production-ready for licensees".

> Several `[SRC: architecture.md §…]` citations point at the trial-1 Obsidian vault (not in the repo archive) — the fuller evidence lives there. When the vault is re-established or the fact turns load-bearing, `engine-verifier` re-derives it against engine source directly.
