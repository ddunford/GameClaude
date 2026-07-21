# Guide — Crowd & NPC AI method

> Read before building any NPC, crowd, or traffic behaviour. The core idea: **a persistent social city feels alive primarily because of the *real players* in it; authored NPCs exist to fill the gaps between them and to seed a few deliberate hotspots — not to simulate a city.** The target is *perceived* density, delivered as cheaply as it can be, client-side wherever it can be. It is done only when the city reads as populated, the cost is inside budget across the whole streamed world, and nothing authored competes with the players who are the point.

## The load-bearing decision: perceived density, not simulated density
This is the defining choice for this discipline on ElseCity, and it is a settled design position (verify the density-spike learnings in the vault / `guides/design-docs.md` before revisiting — `[verify — web pass / vault: pull the density-spike findings and any measured NPC-count budgets]`):
- **Full simulated traffic and a fully-simulated NPC populace is an explicit anti-goal.** A GTA-style traffic simulation — every car and pedestrian a networked, physics-driven, pathfinding agent — is enormous cost (CPU, replication bandwidth, authoritative server state) spent to solve a problem this game largely doesn't have, because **the density comes from real players.** ElseCity is Second Life depth × GTA density × Roblox creator economy — and the *density* pillar is met first by players, not by a simulation of people.
- **Density is composed from three layers, in priority order:**
  1. **Real players** — the primary and best source of life. The city is designed so players concentrate (Neon Hub is where new players start and where trade/social life happens), so the places that must feel busy are busy *with people*.
  2. **Authored client-side ambient crowd** — cheap, non-authoritative, non-replicating "extras" that fill the gaps: background pedestrians, distant figures, ambient vehicles. They are set-dressing that moves. They carry **no authoritative state**, do not replicate, and each client can run its own — because they don't need to agree.
  3. **A few authored hotspots** — deliberate, higher-fidelity pockets of life where a beat needs it (a busy market stall, a street performer, a queue). Rare, hand-placed, and budgeted individually.
- **What this buys:** the city reads dense without a traffic sim's cost or a replication bill for thousands of agents. What it forbids: reaching for full simulation because "a city should have traffic." If a space feels empty, the first question is *why aren't players here* (a design/level question) and the second is *can ambient crowd fill it cheaply* — not *let's simulate more*.

## The two failures this prevents
1. **The simulated-city cost sink.** Thousands of fully-networked, pathfinding, server-authoritative agents grinding the CPU and saturating replication bandwidth to deliver density that real players already provide — cost the game can't afford in a persistent world with a zone-sharded server. → ambient crowd is client-side, cosmetic, and cheap; simulation is reserved, not default.
2. **The empty-at-alpha city.** Crowd/NPC AI activated too late, so the city reads dead at the alpha gate when density is a pillar being judged. → this is a *core-production* system (P2), not a polish pass; it must be populating the city by alpha.

## PRINCIPLES
- **Player density first; author the gaps.** Design and level work concentrate players where the city must feel alive; NPC crowd fills between and beyond them. Never author crowd to do a job the level layout should do (drawing players to a space).
- **Perceived, not simulated.** The goal is the *impression* of a living populace, delivered as cheaply as possible. An NPC the player never scrutinises needs only to read at a distance and in motion; fidelity is spent only where the player gets close.
- **Client-side and cosmetic by default.** Ambient crowd and traffic carry no authoritative state and do not replicate — like ambient audio (`guides/audio.md`) and cosmetic VFX (`guides/vfx.md`), each client can run its own because divergence doesn't matter. Anything an NPC does that *affects* gameplay, currency, inventory, position-that-others-must-agree-on, or a client-reachable interaction is server-authoritative and goes to `network-engineer` + `security-reviewer` (doctrine 11).
- **Budget is designed in.** Every crowd system ships with an active-agent cap, an LOD/detail ladder by distance, and significance/culling before it ships — measured across the *streamed world at density*, not one solo agent. In a dense city the per-agent cost times the crowd is the number that matters; the profiler, not the eye, confirms it.
- **Behaviour reads at a glance and serves the world.** An NPC's behaviour communicates *this is a living place* — purposeful movement, plausible goals, reaction to the player's presence. Aimless drifting or twitching reads as broken and does the opposite of its job. Match behaviour fidelity to how close and how long the player observes it.
- **Never out-shout the players.** Authored NPCs are the backdrop; real players are the foreground. Crowd that is too dense, too loud, too fast, or too attention-grabbing competes with the actual social life that is the pitch. Restraint (`guides/vfx.md`, `guides/level-design.md`) — the smallest crowd that sells the density.
- **Degrade gracefully with the world.** Crowd scales down with distance, streaming, scalability tier, and player count; it never spawns into a streamed-out cell or persists authoritative state on unload (`guides/networking.md`: `EnableServerStreamingOut=0` exists precisely because unloading destroys authoritative actors — so crowd must *not* be authoritative).
- **Prove it in a spike.** A new crowd/behaviour approach is proven in an isolated map — read, cost, and stacking at density — before it enters the main build (doctrine 3). The density spike is exactly this.

---

## The ambient crowd layer — cheap client-side life
The workhorse. The bulk of the "density" is here:
- **Non-authoritative, non-replicating actors** the client spawns and drives locally. They fill sightlines and middle-distance; they do not need to agree between clients and must not carry state anyone else depends on.
- **Cheapest representation that reads at its distance** — instanced/vertex-animated crowds or lightweight skeletal agents up close, impostors/simple animated meshes at distance. Match the technique to the viewing distance; a distant figure needs a fraction of a near one. `[verify — web pass: current UE 5.x crowd techniques — vertex animation / animation-to-texture, mass-entity/MassAI crowd, ISM-driven crowds — and their cost profiles; confirm which are production-ready]`
- **Spawn from and cull to the streamed world** — populate around the player within a radius, despawn beyond it, never spawn into unloaded cells; density scales with the local player count so a busy plaza thins believably rather than doubling up.
- **Plausible, cheap behaviour** — pathing along authored routes/spline networks or a lightweight steering model, not per-agent full navmesh planning where a route suffices. Purposeful-looking motion beats "correct" expensive motion.

## Hotspots — the few high-fidelity pockets
- **Hand-placed, individually budgeted** moments where a beat needs visible, higher-fidelity life (a performer, a stall-holder, a queue, a set-piece crowd). Rare by design; each one is a considered placement, not a spawn rule.
- **Behaviour authored to read on approach** — the player gets close, so fidelity is warranted; a hotspot NPC can carry more animation, reaction, and (if it interacts) real gameplay wiring.
- **Interactive hotspot NPCs cross into gameplay** — the moment an NPC sells something, gives something, or gates something, it is a client-reachable, server-authoritative surface → `network-engineer` + `security-reviewer`, and its interaction UI is `ui-ux-designer`.

## Traffic — the same doctrine, applied to vehicles
- **Ambient traffic is the same cosmetic, client-side, capped layer** — background vehicles on authored routes that read as a moving city, not a simulated road network with per-vehicle physics and collision resolution across clients.
- **No authoritative traffic simulation.** Vehicles the player can't ride or affect need no server state; if a player *can* interact with a vehicle, that specific vehicle is a gameplay/networked object, handled as one, not as part of the ambient layer.
- **Routes, not free navigation.** Spline/lane networks authored by level design give traffic plausible paths cheaply; full autonomous driving AI is out of scope for ambient traffic (the anti-goal).

## NPC behaviour architecture — the tools, matched to fidelity
Use the cheapest architecture that delivers the needed fidelity; do not put a full behaviour tree on a background extra:
- **Distant/ambient** — steering + spline following + animation state, no per-agent planning.
- **Mid / crowd systems** — a data-oriented crowd/mass system where UE provides one, for scale. `[verify — web pass: is Mass Entity / MassAI the right crowd backbone in this UE version, and its maturity]`
- **Close / hotspot / interactive** — behaviour trees / state trees + navmesh where genuine decision-making and navigation are observed. `[verify — web pass: StateTree vs Behavior Tree recommendation for UE 5.x NPC AI]`
The rule mirrors the LOD principle: fidelity — and its cost — is spent where the player looks closely, and stripped where they don't.

## Engine facts live elsewhere
Anything about *how* UE does crowds and AI — Mass Entity / MassAI, navmesh generation and runtime navigation, StateTree/Behavior Tree/EQS, animation-to-texture / vertex-animation crowd techniques, ISM/HISM instancing costs, AI perception — belongs in `guides/unreal-engine.md` with source citations, verified via `engine-verifier` before it's relied on. Do not duplicate it here. Navmesh build is a known gap on this project's toolchain (`guides/tooling-ue.md`) — confirm the build route before depending on runtime navigation. Character *meshes* are `character-artist`; character *motion/rigs* are `animator` (`guides/animation.md`) — this role drives *what NPCs do and how many*, not how they're modelled or rigged.

## Phase activation
Per `guides/production-pipeline.md §3.5`, crowd/NPC AI **activates P2** and is a **core-production system, not polish**: "City density is a pillar; activate past P2 and the city reads empty at alpha." It depends on the character/animation pipeline (P1 spike · P2 build) for the bodies it animates, and on level design having concentrated the player-density layer first. The density approach itself (perceived, not simulated) is a P1 spike learning that must be backported to the vault before P2 build leans on it (doctrine 3).

## QUALITY BAR
Crowd/NPC work is ready to recommend when all of these hold — judged fresh (`qa-visual` for reads/runs, `qa-network` for anything authoritative, `creative-review` for on-pitch), never self-signed:
- **The city reads populated** at the density the space intends — with players first, ambient crowd filling the gaps, hotspots where beats need them.
- **In budget across the streamed world at density.** Active-agent cap, LOD ladder, significance/culling set and *measured* stacked in the real world, not solo; per-agent-times-crowd cost inside the frame and (for anything replicated) the bandwidth budget.
- **Cheap and cosmetic by default.** Ambient crowd/traffic is client-side, non-replicating, non-authoritative; nothing background carries state anyone else depends on.
- **Reads at a glance.** Behaviour looks purposeful at its viewing distance; no aimless drift or twitch; fidelity matched to observation distance.
- **Never out-shouts players.** Crowd is backdrop, not foreground; density/motion/attention restrained so real social life stays the focus.
- **Degrades with the world.** Scales down by distance/streaming/scalability/player-count; never spawns into unloaded cells; no authoritative state on a streamed-out actor.
- **Authoritative where it must be, and only there.** Any NPC that affects gameplay, currency, inventory, agreed position, or is client-reachable is server-authoritative, paired with `network-engineer` and hardened by `security-reviewer` (doctrine 11).
- **Not a simulation.** No full traffic sim or fully-simulated populace crept in; the anti-goal held.

## COMMON FAILURE MODES
- **Simulated-city cost sink.** Thousands of networked authoritative agents delivering density players already provide. → perceived not simulated; client-side cosmetic default; simulation reserved.
- **Empty-at-alpha.** Crowd treated as polish and activated late; city reads dead at the density-pillar gate. → core-production P2 system; populating by alpha.
- **Uncapped / unbudgeted crowd.** No agent cap, no LOD, no culling; fine in a test scene, a frame cliff (or a bandwidth blowout) at density. → budget designed in; measure stacked in the streamed world.
- **Authoritative ambient crowd.** Background extras replicated or holding server state, burning bandwidth and dying on cell unload. → cosmetic, client-side, non-replicating; only real-interaction NPCs are authoritative.
- **Broken-looking behaviour.** Aimless drift, twitching, agents walking into walls or through each other in view. → purposeful cheap behaviour; fidelity matched to distance; readable pathing.
- **Crowd out-shouting players.** Too dense/loud/fast, competing with the social life that is the point. → restraint; backdrop not foreground.
- **Unhardened interactive NPC.** A vendor/quest NPC treated as cosmetic, exposing a client-reachable exploit. → route to `network-engineer` + `security-reviewer`; each check names the exploit.
- **Navmesh assumed.** Runtime navigation depended on without confirming the navmesh build route on this toolchain. → verify via `engine-verifier`; prefer authored routes for ambient agents.

## CHECKLIST
**Before building:**
- [ ] The density target for the space is named, and the player-density layer (level design concentrating players) is accounted for first.
- [ ] Each layer decided: where ambient crowd fills, where the few hotspots sit, whether any traffic is needed.
- [ ] A budget set: active-agent cap, LOD ladder, significance/culling target — measured at density, not solo.
- [ ] Behaviour architecture chosen per fidelity tier (steering/spline vs crowd system vs BT/StateTree), cheapest that reads.
- [ ] For a new approach: an isolated spike proving read + cost + stacking (doctrine 3); density findings backported to the vault.
- [ ] Any NPC that affects gameplay/currency/position or is client-reachable flagged for `network-engineer` + `security-reviewer`.

**During building:**
- [ ] Ambient crowd/traffic is client-side, non-replicating, non-authoritative; spawns/culls with the streamed world; never into unloaded cells.
- [ ] Density scales with local player count; distance LODs and culling in; degrades across scalability tiers.
- [ ] Behaviour reads purposeful at its viewing distance; hotspots higher-fidelity on approach; no drift/twitch/wall-walking in view.
- [ ] Interactive NPCs wired server-authoritative; interaction UI to `ui-ux-designer`.
- [ ] Profiled stacked in the real streamed world — frame and (if replicated) bandwidth.

**Before recommending done:**
- [ ] Quality bar met; budget confirmed by measurement at density.
- [ ] Any engine/AI-behaviour claim (Mass, navmesh, StateTree/BT, crowd technique) verified via `engine-verifier`.
- [ ] Anything authoritative verified by `qa-network` (server + 2 clients + negative test) and hardened by `security-reviewer`.
- [ ] Judged fresh by `qa-visual` (reads + runs) and `creative-review` (on-pitch, does the city feel alive without out-shouting players) — never self-run.
- [ ] One-line done recommendation to the Producer — never a self-sign-off.

## Sources
Craft grounded in crowd-simulation, game-AI, and UE population practice — pin exact references in the web pass:
- **Epic / Unreal AI & crowd documentation** — Mass Entity / MassAI, navigation/navmesh, StateTree, Behavior Tree, EQS, AI Perception; crowd rendering (vertex animation / animation-to-texture, instancing). `[verify — web pass]`
- **City Sample / MassAI** — Epic's own large-crowd city reference and what it costs. `[verify — web pass: The Matrix Awakens / City Sample crowd approach and figures]`
- **Steering & crowd behaviour** — Reynolds boids/steering, ORCA/RVO for local avoidance, as the cheap-behaviour backbone. `[verify — web pass]`
- **Perceived vs simulated density** — the ElseCity density-spike findings in the vault are the authority here, not general literature; pull them before revisiting the anti-goal. `[verify — vault]`
- Engine mechanics belong in `guides/unreal-engine.md`; character meshes in `guides/character-art.md`; motion/rigs in `guides/animation.md`; authority/replication in `guides/networking.md`; cosmetic-vs-authoritative logic mirrors `guides/vfx.md` and `guides/audio.md`.
