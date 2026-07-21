# Guide — Narrative & worldbuilding method

> Read before writing any story, lore, in-world text, or signage. The core idea: **narrative in a persistent social sandbox is mostly *environmental and systemic*, not cutscene-and-cutscene — the world tells its own story through place, sign, and behaviour, and the writing exists to give the player's own stories a stage, not to author a plot they sit through.** It is done only when the tone is consistent, the lore is coherent and non-contradicting, every in-world word earns its place, and a fresh reader judges it on-pitch.

## What this role owns, and what it defers
This role owns **story, worldbuilding, lore, in-world text and signage, environmental narrative, and the tone/voice of everything written in the world.** It absorbs the narrative remit that was bundled into the `narrative-ux` stub — narrative is its own discipline here, not a hat on UI logic. It does **not** own:
- **The vision, pillars, anti-goals, and emotional target** — those are `creative-director`'s (`agents/creative-director.md`). Narrative *serves* the vision; it does not set it. When a lore choice and a pillar conflict, the pillar wins.
- **How environmental storytelling is physically dressed** — props, wear, decals, clustering — that is `environment-art` (`guides/environment-art.md §2`, "Human traces"). Narrative decides *what story a space tells and who lives there*; the environment artist *builds the traces that tell it*. The two are a pair: this role writes the brief, that role dresses it.
- **UI copy layout, information hierarchy, and readability on screen** — that is `ui-ux-designer` (`guides/ui-ux.md`). Narrative supplies the *words and voice*; UI owns *how they are presented*.

## The two failures this prevents
1. **Plot imposed on a sandbox.** A branching authored storyline written for a game whose actual pleasure is *emergent* — player-to-player social life, creation, exploration. The player skips the cutscene to get back to the thing they came for, and the writing budget is spent on content nobody consumes. In a persistent world the narrative is the **setting and the systems**, not a plot the player is marched through. Author the stage; let the players author the play.
2. **Incoherent world.** Lore that contradicts itself district to district, a tone that lurches from earnest to ironic to grimdark with no throughline, signage in five different voices — so the world reads as assembled by strangers, because it was. A world-bible that is actually consulted is what stops this; lore in someone's head is lore that will contradict itself.

## PRINCIPLES
The craft rules that hold across everything written into the world.
- **Setting over plot; systems over script.** The primary narrative surface is the *world itself* and the *systems the player lives in* — where they are, what the place implies happened here, what the rules of this district say about who runs it. Authored linear story is the smallest, last layer, reserved for the few moments that need it (onboarding, a district's introduction, a set-piece).
- **Environmental narrative is the main channel.** Most of the story is told without words — through place, arrangement, wear, and juxtaposition. This is the "human traces" discipline (`guides/environment-art.md §2`); narrative's job is to *write the brief* those traces answer: *who is here, what do they do, what happened, why should the player care.* Every dressed space should answer those questions before a single line of text is written.
- **Show through the world before you tell in text.** A door that leads somewhere else says more than a paragraph explaining that doors lead somewhere else. Reach for in-world evidence (a place, an object, a behaviour) before reaching for exposition. Text is the fallback, not the default.
- **Every in-world word earns its place and matches the world's voice.** Signage, notices, graffiti, item names, district names, terminal text — each is diegetic (it exists *in* the world, written by someone *in* the world) and must sound like its author. A civic sign and a scrawled tag are not the same voice. Reserve loud, explicit text for where the player *must not* miss the meaning (`guides/level-design.md`: match cue certainty to importance) — over-labelling a world reads as a theme park, not a place.
- **Tone is a contract — hold it.** The world has one coherent tone (set with `creative-director` against the pillars and anti-goals) and every written thing honours it. ElseCity is *believable contemporary city as a door into wonder* — Ready Player One / Roblox optimism, **not cyberpunk dystopia** (an explicit anti-goal). A grimdark tag or an ironic sneer in the wrong place breaks the contract as surely as a bug.
- **Worldbuilding underpins district identity.** Each district's identity — who runs it, what it is for, why it looks and sounds as it does, whether it is safe — is a *worldbuilding* fact before it is an art or level fact. The district's rules (safe vs unsafe, `Zone.SafeHub`) are narrative made mechanical: the boundary is visually unmistakable *because the world says these are different places*. Feed district identity upstream to level design and art, not after they've built.
- **The world-bible is the single source of truth.** Lore, tone, voice, naming conventions, and district identity live in the design vault as *current fact* (`guides/design-docs.md`, doctrine 12 — no changelog, no "old lore said"), owned via `knowledge-keeper`. If it isn't in the bible, it isn't canon; if two things in the bible conflict, one is a defect. Prefer a surgical edit to the vault over restating lore in a task.
- **Restraint is a narrative choice.** The ordinary is load-bearing (`creative-director`). A quiet, unexplained detail the player *discovers* beats a paragraph that explains it to them. Leave gaps for the player to fill — a persistent social world's best stories are the ones players tell each other, and negative space is where those grow.

---

## Environmental narrative — writing the brief the world answers
The bulk of the work. For each space, before art dresses it, produce a short **narrative brief** that `environment-art` and `level-design` build to:
- **Who is here, and what do they do?** The invisible inhabitants whose traces dress the space. A market stall implies a trader; a barricade implies a threat and someone who feared it.
- **What happened here, and what is happening now?** Wear tells the story of use (`guides/environment-art.md §2`); narrative decides *which* story. A cleared path vs an overgrown one is a sentence written in vegetation.
- **What should the player feel and infer?** The emotional beat this space serves (ranked against `creative-director`'s beats), and what the player should *conclude* without being told.
- **How does it connect to the district's identity?** Every space is evidence for the larger worldbuilding claim about its district.
Environmental storytelling techniques (juxtaposition, arrangement, wear-as-narrative, the "narrative decal" — a specific mark of a specific person or event) are catalogued in `guides/environment-art.md §2`; this role chooses *what they say*, not how they're rendered.

## In-world text & signage — the diegetic writing surface
Every word that appears *inside* the fiction. Each has an in-world author and must sound like them:
- **Wayfinding & civic signage** — district names, street signs, transit, warnings. Doubles as the player's real wayfinding system (`guides/level-design.md`: landmarks as orientation), so it must be *functional first, flavourful second*. A safe→unsafe boundary sign is a gameplay-critical cue (`Zone.SafeHub`) — its certainty must match its stakes.
- **Ambient/incidental text** — graffiti, posters, notices, stickers, shopfront copy. The texture of a lived-in city; the density and voice of this text *is* a district's character. Written to imply authors, not to narrate.
- **Interactive/terminal text** — anything the player reads by choosing to (a notice board, a terminal, an item description). This is where optional lore lives — opt-in, skippable, never gating.
- **Item & entity names** — coherent naming conventions (`guides/design-docs.md`) so the world's vocabulary is consistent. Naming is worldbuilding: a "district" vs a "borough" vs a "sector" each imply a different world.
- **Localization from day one.** Every in-world string is externalized for translation from the start (`guides/production-pipeline.md §3.5`: localization activates P1 — externalize strings early). Bake no player-facing text into art or code; hand strings to the localization pipeline. Retrofitting is far costlier than designing it in.

## Tone & voice — the consistency contract
- **One world tone, set with the Creative Director.** Derived from the pillars and anti-goals; documented in the world-bible as the reference every written thing is checked against.
- **Multiple in-world voices, one authorial hand.** Different in-world authors (civic, criminal, corporate, personal) sound different — but all are written by one discipline holding one tone, so the *variety* reads as a living city rather than an *inconsistency* that reads as a mistake.
- **Voice guide per district / faction.** A short, concrete voice sheet (vocabulary, register, what they'd never say) so signage and text stay in character as the world scales and other disciplines write copy against it.

## Working with the other disciplines
- **`creative-director`** sets the vision and tone target; narrative executes within it and escalates any lore choice that touches the pillars. Spikes (a district's narrative concept) go to `creative-director` before integration (doctrine 3), and to `creative-review` fresh for the on-pitch judgement.
- **`environment-artist`** receives the per-space narrative brief and builds the traces; narrative reviews the dressed result for *does it tell the story it was briefed to*.
- **`level-designer`** receives district identity and the wayfinding/landmark narrative; the two co-own that district boundaries are "visually unmistakable" — a narrative claim made spatial.
- **`ui-ux-designer`** receives the words and voice for menus/HUD/onboarding; owns their on-screen presentation.
- **`sound-designer`** — the world's voice includes its sound (a district's ambient chatter, PA announcements); coordinate diegetic audio text with its written counterpart.
- **`knowledge-keeper`** — all lore, tone, and naming conventions land in the vault as current fact; narrative never keeps canon only in a task or a head.

## Engine & pipeline facts live elsewhere
This guide is craft, not engine. Anything about *how* text is rendered, streamed, or localized in UE — string tables, `FText` vs `FString`, `StringTable` assets, localization dashboard, data-driven dialogue systems — belongs in `guides/unreal-engine.md` with a source citation, verified via `engine-verifier` before it's relied on. Do not duplicate it here. `[verify — web pass: current UE 5.x localization/StringTable workflow and any first-party narrative/dialogue tooling worth adopting]`

## Phase activation
Per `guides/production-pipeline.md §3.5`, narrative & worldbuilding **activates P1–P2**: it can run light through Stage 0 (ideation), but must be active as districts take shape, because worldbuilding underpins district identity and district identity is upstream of level design and environment art. Its heaviest load is authoring district identity and the in-world text pass as spaces are built (P1–P2); by content-lock (P3) the world-bible and signage are complete and locked.

## QUALITY BAR
Narrative work is ready to recommend when all of these hold — judged by a fresh pass (`creative-review` for on-pitch), never self-signed:
- **On-pitch.** Tone and content honour the pillars and anti-goals; nothing drifts toward the cyberpunk-dystopia anti-goal or any other off-pitch register.
- **Coherent.** No lore contradicts other lore; the world-bible is the single source of truth and is internally consistent; naming conventions hold across the world.
- **Environmental first.** The story is told through place, arrangement, and behaviour before it is told in text; every dressed space has a narrative brief it answers.
- **Every word earns its place.** No exposition dump, no over-labelled theme-park signage; text reserved for where meaning must not be missed, with certainty matched to stakes.
- **Voice-consistent.** Each in-world author sounds like themselves; the variety reads as a living city, not an inconsistency.
- **District identity fed upstream.** Each district's who/what/why is documented and handed to level design and art *before* they build, not reverse-engineered after.
- **Localization-ready.** Every player-facing string is externalized; nothing baked into art or code.
- **Serves the sandbox.** The writing gives the player's own stories a stage; it does not impose a plot they must sit through.

## COMMON FAILURE MODES
- **Cutscene-brain in a sandbox.** Authoring a linear plot for an emergent social world; budget spent on content the player skips. → setting over plot; systems over script; author the stage.
- **Incoherent world.** Contradicting lore, lurching tone, five-voiced signage. → the world-bible as single source of truth; one tone, many voices, one authorial hand.
- **Exposition dump.** Telling in text what the world could show; paragraphs on terminals nobody reads. → show through the world first; text as fallback; opt-in lore only.
- **Theme-park over-labelling.** Every surface signposted, every meaning spelled out; the city reads as a set, not a place. → match cue certainty to stakes; restraint; leave gaps for the player.
- **Off-pitch tone.** A grimdark or ironic voice creeping in against the pillars. → tone is a contract checked against the vision; `creative-review` fresh.
- **Lore in a head, not the bible.** Canon that lives only in a session or a task, so it contradicts itself next time. → everything to the vault as current fact via `knowledge-keeper`.
- **Baked strings.** Player-facing text hardcoded into art or code, blocking localization. → externalize every string from day one.
- **District identity invented downstream.** Level design or art guessing who a district is because narrative hadn't decided. → identity documented and handed upstream before the build.

## CHECKLIST
**Before writing:**
- [ ] The world tone and pillars re-read; this work checked against the anti-goals.
- [ ] The world-bible consulted; no contradiction with existing canon; naming conventions applied.
- [ ] For a space: a narrative brief (who / what happened / what to feel / district link) written *before* art dresses it.
- [ ] For a district: its identity documented and handed to `level-designer` and `environment-artist` upstream.

**While writing:**
- [ ] Environmental / systemic channel exhausted before reaching for text.
- [ ] Each in-world string has a named in-world author and matches that voice.
- [ ] Signage that doubles as wayfinding is functional-first; safe/unsafe boundary cues carry their stakes.
- [ ] Every player-facing string externalized for localization; nothing baked in.
- [ ] Optional lore is opt-in and skippable; nothing gates play on reading.

**Before recommending done:**
- [ ] Quality bar met; world-bible updated to current fact via `knowledge-keeper` (doctrine 12).
- [ ] Any engine/localization-tooling claim verified via `engine-verifier`.
- [ ] Dressed spaces reviewed against their narrative brief (with `environment-artist`).
- [ ] Judged fresh by `creative-review` (on-pitch) — never self-run.
- [ ] One-line done recommendation to the Producer — never a self-sign-off.

## Sources
Craft grounded in the standard game-narrative and worldbuilding literature — pin exact references in the web pass:
- **Environmental storytelling** — the shared body with `guides/environment-art.md §2` (set dressing with purpose, wear-as-narrative, narrative decals); not duplicated here. `[verify — web pass]`
- **Environmental / systemic narrative design** — the standard writing on story told through world and systems rather than cutscene (e.g. the "narrative is the setting" tradition in immersive-sim and open-world design). `[verify — web pass: pin canonical talks/texts — Harvey Smith / Matthias Worch environmental storytelling, Emily Short on systemic narrative]`
- **Worldbuilding & tone consistency** — the world-bible discipline. `[verify — web pass]`
- Vision, pillars, anti-goals, and emotional beats live with `creative-director` / `guides/design-docs.md`, not here. Engine/localization mechanics live in `guides/unreal-engine.md`.
