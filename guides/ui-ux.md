# Guide — UI/UX method

> Read before designing or building any screen, HUD element, menu, or flow. The core idea: **UI is one discipline, not two — the logic (what it does, which state it shows, how the flow moves) and the visuals (layout, hierarchy, type, feedback) are the same problem, and a screen is done only when a first-time player can find it, read it, understand it, and operate it on a gamepad, without a manual — judged by someone who didn't build it.**

## Why this is one owner, not two

UI here was a structural defect: "UMG logic" lived in one stub and "UMG visuals" in another, so every screen was owned by two roles and therefore by neither. A layout decision *is* a hierarchy decision *is* a flow decision — you cannot lay out a HUD without deciding what matters, and you cannot decide what matters without knowing what the screen is for. This guide and `agents/ui-ux-designer` reunite them. The logic and the pixels answer to the same person.

## The failures this prevents
1. **Pretty-but-broken / functional-but-unreadable.** The split's two natural failure states: a gorgeous screen you can't operate, or a working screen you can't read. Both ship when "visuals" and "logic" are graded separately and nobody owns the whole.
2. **The desktop-mouse assumption in a controller game.** UI designed with a cursor and retrofitted to a gamepad — no default focus, no focus navigation, tiny click targets, wrong or absent button prompts. The controller player finds the interface literally inoperable, and it's discovered late because the builder tested with a mouse.

## PRINCIPLES
The craft rules that hold across every screen. Sections below give the specifics; these say what good looks like.
- **The player's goal outranks the feature list.** Design the *task* ("find a friend and join them", "place this prop", "read my health in a fight"), then the screen that serves it — never a menu that mirrors the code's data model.
- **Hierarchy is the whole job.** Every screen has exactly one thing the eye should hit first, a second tier it finds next, and a rest it can ignore until needed. If everything is emphasised, nothing is. Establish the tier before choosing a single colour or size.
- **Readable before beautiful.** A player who can't parse the screen is blocked; art can't fix a broken hierarchy. Legibility, contrast, and target size are correctness, not polish.
- **Every control advertises and confirms.** It looks operable (affordance) *before* the press and confirms it fired (feedback) *on* the press — inside the correction cycle (`guides/game-feel.md`, ~100 ms). A control that does neither reads as broken even when it works.
- **Gamepad is a first-class citizen, designed in.** Focus navigation, a sensible default focus, and correct button glyphs are part of the first design, not a port. If it isn't operable on a controller, it isn't done.
- **One component system, reused everywhere.** Buttons, panels, sliders, prompts, list rows are shared widgets with one look and one behaviour. A bespoke one-off is drift, and drift is what players read as "unpolished."
- **Never colour alone.** State carried only by hue is invisible to a colourblind player and weak in bright/dark conditions — pair colour with icon, shape, position, or text, always.
- **Flows have a shape and an exit.** Every screen answers where-am-I / what-can-I-do / how-do-I-leave. No dead-ends, no modal stacked on modal, no state the player can get stuck in.
- **Present, don't decide.** UI displays server-authoritative state (currency, inventory, health) and *requests* changes through validated endpoints; it never owns the truth. The client UI is hostile until proven (`agents/security-reviewer`, doctrine 11).
- **Data-drive the variable content.** Text, layouts that vary by content, and tuning live in tables/localisation sources, not hardcoded in the widget — so content and translation iterate without a recompile, and localisation length changes don't break layout.

---

## Information hierarchy — the first decision, before any pixel

Decide the tiers before you style anything. The reliable method:
- **Rank the elements by how badly the player needs them, and when.** In-fight HUD: health/immediate-threat first, resource second, map/objective third, cosmetic/social last. A settings screen: the thing they came to change first.
- **Encode the rank with more than one channel.** Size, position (the eye starts top-left in LTR reading order and returns to a stable "home" like screen centre/bottom-centre for the HUD), value contrast, and whitespace all signal importance — spend them on the top tier and *withhold* them from the rest. (The value/focal-point theory is `guides/art-direction.md`; here it's applied to a screen.)
- **Progressive disclosure.** Show the tier the player needs now; put the rest one deliberate step away. A creator-tool palette that shows every primitive at once is a wall; grouped, searchable, and revealed on demand it's usable. The cost of hiding is a click; the cost of showing everything is paralysis.
- **Group by task, not by data type.** Related controls sit together (Gestalt proximity); a divider or a panel says "these belong together." A screen laid out to mirror the underlying struct is a defect.

## Layout & grid — structure the frame

- **A grid and consistent spacing.** Align to a grid; use a small spacing scale (e.g. multiples of 4/8 px) rather than eyeballed gaps — consistent rhythm is most of what reads as "clean." `[verify — web pass: the 8-point grid convention and its adoption]`
- **Anchors and safe areas for a game that ships to many resolutions and to TV.** UMG anchors keep elements positioned across aspect ratios; a HUD must respect **title-safe / action-safe** margins so nothing critical is clipped on a TV or by an overscan display. Common guidance keeps critical UI inside ~**90% action-safe / ~80–85% title-safe** of the screen, but confirm the exact figures for target platforms `[verify — web pass: current title-safe / action-safe percentages, esp. console cert requirements]`.
- **Whitespace is structural.** Negative space groups, separates, and gives the eye rest; a screen packed corner-to-corner has no hierarchy (`guides/art-direction.md`, negative space).
- **Design for the longest string.** Layout must survive localisation (German/Finnish run long) and dynamic numbers (a 7-digit currency); test with the longest content, not the demo value.

## Type & readability — the correctness floor

- **Minimum sizes, and test at distance.** Text legible at the *player's actual viewing distance* — a phone at 30 cm and a TV at 3 m are different problems; the "10-foot UI" (couch/console) needs notably larger type and targets than a desktop. Verify minimums against platform guidance `[verify — web pass: console/TV minimum font-size and 10-foot UI guidance]`.
- **Contrast against a moving world.** HUD text sits over gameplay that can be any colour — never trust the background. Use a scrim, outline, drop-shadow, or backing panel so text holds contrast over both a bright sky and a dark alley. WCAG's **4.5:1** for normal text / **3:1** for large text is the accepted floor to aim at `[verify — web pass: WCAG 2.x contrast ratios and any game-specific accessibility guidance, e.g. Game Accessibility Guidelines / XAGs]`.
- **A small type scale, not per-element sizes.** A few defined roles (title / heading / body / caption) reused everywhere; arbitrary per-screen sizing is drift.
- **Line length and alignment.** Left-align body text (LTR); keep line lengths readable; avoid centre-aligning long runs.

## Feedback & affordance — the control must speak

Every interactive element has visible states and a response, and the response lands in the correction cycle (`guides/game-feel.md`):
- **The state set:** default, **hover/focus** (identical importance — focus is the gamepad's hover), pressed/active, disabled, and where relevant selected/loading. A disabled control looks disabled (and ideally says *why*); an enabled one looks pressable.
- **Confirm every action.** A press produces an immediate perceptible change — the button depresses, a sound fires, the value ticks, a spinner appears. Silence on a press reads as a dropped input even when it landed (doctrine-adjacent to game-feel's "every action gets a reaction").
- **Optimistic vs. authoritative feedback.** For a server-authoritative action (buy, trade, equip), the UI may show *pending* immediately for feel, but must reconcile to the server's result and show failure clearly — never show success the server didn't grant. This is the UI face of client prediction (`guides/game-feel.md`).
- **Errors are specific and recoverable.** "Not enough credits" beats "Error"; the player is told what went wrong and what to do. No dead-end error state.

## Input & gamepad — first-class, not a port

A controller game whose UI assumes a mouse is broken for a large share of players. The requirements:
- **A default focus on every screen.** When a screen opens, something is focused, so the D-pad/stick has somewhere to start. No default focus = a gamepad player facing a screen that ignores them.
- **Legible focus navigation.** The focused element is unmistakable (a strong focus ring/highlight — not a subtle tint), and directional navigation moves between elements predictably. UMG's focus/navigation system drives this; explicit navigation rules where the automatic ones misorder `[verify — web pass: UMG focus navigation API — SetNavigationRuleExplicit / navigation config, current names]`.
- **Correct button prompts, dynamically.** Prompts show the *current device's* glyphs (Xbox / PlayStation / keyboard) and update when the player switches device mid-session. A "Press A" label to a PlayStation player is a defect.
- **Both input paths, always.** Mouse/keyboard and gamepad both fully operate every screen — including the creator tool. A mouse-only interaction (drag-only, hover-only tooltip carrying essential info) locks out the controller player; provide an equivalent.
- **Target size and spacing for a cursor and a stick.** Click/focus targets large enough and spaced enough to hit without precision; tiny adjacent targets punish both a thumbstick and a touchscreen.
- **Remappable input** where feasible — a baseline accessibility expectation, not a luxury.

## UX flows & state — the machine behind the screens

- **Map the flow as a state machine before building screens.** Entry → each state → transitions → exit. Draw it; a flow you can't draw is a flow with holes.
- **No dead-ends.** Every state has a way forward and a way back (Back/Cancel that actually returns). The player can always reach the main game from anywhere.
- **Escape modal-hell.** A modal interrupts; a stack of modals traps. Prefer non-modal panels; when a modal is right, one at a time, dismissible, with the consequence stated. A confirm-dialog for a reversible action is friction; for an irreversible one it's mandatory.
- **Preserve state across navigation.** Returning to a screen restores where the player was (scroll position, selected tab) rather than resetting — losing their place reads as the game forgetting them.
- **Consistency of interaction.** The same gesture does the same thing everywhere (Back always cancels, the same button always confirms); an inconsistent verb is a hidden tax on every screen.

## HUD — the in-play surface

- **Diegetic where it strengthens immersion, non-diegetic where it must be unmissable.** A holographic wrist display is diegetic; a hard-fail warning is non-diegetic and loud. Choose per element by how badly it must be seen, not by a blanket style rule.
- **Show what's needed now; fade the rest.** A HUD element that's constant clutter when it's not relevant (a full ability bar during a quiet social stroll) can fade/contextualise. But **never hide safety-critical or state-critical info** to reduce clutter — the fix for a busy HUD is hierarchy, not deletion.
- **Anchor to stable, edge-safe positions** (respecting safe areas above) so the eye always knows where to look; a HUD element that moves is a HUD element the player loses.
- **The HUD reads over any background** (see contrast) and holds in both lighting registers (`guides/lighting.md` day/night) — verify in the darkest and brightest scene, not a mid-grey test.

## Accessibility — the basics, non-negotiable

Not a separate pass — designed in from the first screen:
- **Never colour alone** (restated because it's the most-broken rule): every colour-coded state also has an icon/shape/text.
- **Contrast and text size** meet the floors above; a text-size option and a UI-scale option where feasible.
- **Colourblind-safe palettes** — test against the common types (deuteranopia/protanopia/tritanopia); don't rely on red-vs-green.
- **Reduce-motion** — an option to damp screen-wide animation, parallax, and heavy transitions (ties to `guides/game-feel.md`'s reduce-motion for shake/juice).
- **Remappable controls** and both input paths (above).
- **Subtitles/caption support** where audio carries meaning (owned with `agents/sound-designer` for the audio side).

`[verify — web pass: align the accessibility floor to a named standard — Game Accessibility Guidelines, Xbox Accessibility Guidelines (XAGs), or WCAG 2.2 — and pull exact thresholds]`.

## QUALITY BAR
A screen/flow is ready to recommend when all of these hold — judged by a fresh pass (`qa-visual` for readable-and-operable, `creative-review` for on-pitch), never self-signed:
- **Legible.** A first-time player parses the hierarchy in seconds; the top-tier element is hit first; text meets size/contrast floors over the real (moving, lit) background, in both registers.
- **Operable on a gamepad.** Every screen has a default focus, an unmistakable focus highlight, predictable navigation, and correct dynamic button prompts; no interaction is mouse-only.
- **Every control speaks.** Hover/focus, pressed, disabled states present; every action confirms within the correction cycle; errors are specific and recoverable.
- **Consistent.** Built from the shared component library; the same gesture does the same thing everywhere; type/spacing/colour hold to the system.
- **Accessible.** No meaning by colour alone; colourblind-safe; contrast and size floors met; reduce-motion and remappable input available.
- **Flow is whole.** State machine has no dead-ends; Back/Cancel returns; no modal-hell; state preserved across navigation; the player can always reach the game.
- **Honest about authority.** UI displays server truth and requests changes through validated endpoints; it never decides currency/inventory/state; pending vs confirmed is shown correctly.
- **Localisation- and resolution-proof.** Survives the longest string and the widest number; respects anchors and safe areas across aspect ratios and on TV.

## COMMON FAILURE MODES
- **Cluttered / unreadable HUD.** Everything emphasised, no hierarchy, text lost over the background. → rank the tiers; encode rank with size/position/contrast/whitespace; scrim the text; fade the non-urgent (never the critical).
- **No feedback.** A control that gives nothing on hover/focus/press — reads as broken input. → the full state set on every control; confirm every action in the correction cycle.
- **Inconsistent components.** Bespoke one-off buttons/panels; the same action styled or behaving differently across screens. → one shared component library; the same gesture, the same result, everywhere.
- **Modal-hell / dead-end flows.** Modals stacked on modals; a screen with no way back; state the player gets stuck in. → map the flow as a state machine; non-modal by default; a real Back everywhere; no dead-ends.
- **Inaccessible.** Meaning by colour alone; type too small; contrast too low; no reduce-motion; no remap. → the accessibility basics, designed in, tested against a named standard.
- **Mouse-only in a controller game.** No default focus; invisible focus; wrong glyphs; drag-only or hover-only essential interactions. → gamepad as a first-class citizen from the first design; both input paths operate everything.
- **UI that decides truth.** The client computing currency/inventory/health, or submitting an unvalidated mutation. → present server state; request changes through a validated endpoint (`security-reviewer`); show pending vs confirmed honestly.
- **Layout that breaks on real content.** Designed to the demo string and one resolution; explodes on a long translation or a TV's safe area. → design for the longest string and the widest number; anchors + safe areas; test at target distance.

## CHECKLIST
**Before building (design):**
- [ ] The player's *task* for this screen is stated; the screen serves the task, not the data model.
- [ ] Element tiers ranked; the one first-glance element identified; rank encoded by more than colour.
- [ ] Flow drawn as a state machine — entry, states, transitions, exit — with no dead-ends.
- [ ] Component library checked: reuse an existing widget, or justify a new shared one (never a one-off).
- [ ] Gamepad plan: default focus, navigation order, prompt glyphs — decided now, not later.
- [ ] Accessibility plan: colour+second-channel, contrast/size targets, reduce-motion, remap.

**During the build:**
- [ ] Built from the shared components; type/spacing/colour hold to the system.
- [ ] Every control has default / hover-focus / pressed / disabled states and confirms actions in the correction cycle.
- [ ] Fully operable on a gamepad: default focus set, focus highlight unmistakable, navigation predictable, glyphs dynamic; and fully operable on mouse/keyboard — no interaction locked to one path.
- [ ] Text holds contrast over the real background in both lighting registers; sizes meet the target-distance floor.
- [ ] Anchors + safe areas set; tested with the longest string and the widest number, across aspect ratios.
- [ ] Any state shown is read from server-authoritative data; any mutation goes through a validated endpoint; pending vs confirmed shown honestly.

**Before recommending done:**
- [ ] Quality bar met.
- [ ] Walked on a controller *and* mouse/keyboard by a fresh pass — `qa-visual` (readable + operable, from the captured frame and the walked flow) and `creative-review` (on-pitch), never self-run.
- [ ] Any client-callable endpoint the UI hits went to `security-reviewer`.
- [ ] Fixes applied and re-verified on the saved state.
- [ ] One-line done recommendation to the Producer — never a self-sign-off.

## Sources
Craft grounded in the standard UI/UX and game-UI literature — pin exact editions/figures in the web pass:
- **Nielsen Norman Group** — usability heuristics, information hierarchy, progressive disclosure `[verify — web pass]`.
- **WCAG 2.x** — contrast ratios (4.5:1 / 3:1), text-size and non-colour-alone guidance `[verify — web pass]`.
- **Game Accessibility Guidelines** and **Xbox Accessibility Guidelines (XAGs)** — the games-specific accessibility floor, remapping, subtitle/caption expectations `[verify — web pass]`.
- **Console platform cert / "10-foot UI" guidance** — title-safe / action-safe margins, minimum font sizes, gamepad-first expectations `[verify — web pass]`.
- **Unreal UMG documentation** — anchors, focus/navigation, Common UI for input-agnostic and platform-aware UI `[verify — web pass: current Common UI capabilities and API names]`.
- Diegetic/non-diegetic HUD taxonomy (Fagerholt & Lorentzon, *Beyond the HUD*) `[verify — web pass]`.

Feedback timing (the correction cycle, ~100 ms) and juice/reduce-motion are **not** duplicated here — they live in `guides/game-feel.md`. Visual-hierarchy theory (value, focal point, colour ratios, negative space) lives in `guides/art-direction.md`. Engine-behaviour facts (UMG/Common UI/Slate specifics) belong in `guides/unreal-engine.md` with source citations once verified.
