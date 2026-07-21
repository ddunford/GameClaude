# Guide — Accessibility method

> Read before designing any player-facing surface. The core idea: **inclusive design is decided while a system is being built, not bolted on after — every piece of critical information reaches the player through more than one channel, and the game is checked against a recognised standard, not invented rules.** For an all-ages world with a mixed audience, accessibility is reach, not charity.

## The failures this prevents
1. **Bolt-on-too-late.** Remapping, captions, and colourblind-safe encoding attempted after art-lock and system-freeze, when they can only be partial and expensive — or quietly dropped.
2. **Single-channel information.** A state carried by colour alone, a threat signalled by sound alone, an action that needs one specific input — invisible or impossible to a player who can't use that channel.
3. **Conformance-by-memory.** Claiming "it's accessible" against half-remembered rules instead of a cited standard, so the claim can't be checked and the gaps ship.

## PRINCIPLES
- **Design-in, never bolt-on.** Raise the accessibility requirement while the system is being designed; a decision made after the build often can't be added without rework.
- **More than one channel for anything critical.** The load-bearing rule across every category: never colour alone, never audio alone, never one input path. Redundant encoding is the mechanism of accessibility.
- **Options plus good defaults.** Offer the setting (remap, caption size, hold-vs-toggle, reduce-motion) *and* ship a sensible, accessible default — an option behind a bad default helps no one.
- **Align to a recognised standard.** Check against established game-accessibility guidance and platform requirements; cite the guideline, don't assert from memory.
- **Accessibility overlaps usability.** Most of it is just good design — legibility, clarity, feedback, consistency benefit everyone. `guides/ui-ux.md` owns the UI basics; this guide owns the depth across all four channels and the standards.
- **The player's experience outranks the checklist** (doctrine 9). A ticked box while a real player is blocked means the check is wrong.

## The four channels
### Input / motor
- **Full remapping** of every control; no action locked to one physical input.
- **No required simultaneous or rapid-repeat inputs** without an alternative (hold-to-X with a toggle option; no unavoidable button-mash).
- **Adjustable sensitivity, timing, and difficulty**; generous or optional time limits where the design allows.
- Gamepad as a first-class citizen (shared with `guides/ui-ux.md`): default focus, focus navigation, correct glyphs.

### Visual
- **Legible minimum text size** and scalable UI; never assume the player sits close to a large screen.
- **High-contrast** text and critical elements; meet a contrast target `[verify — web pass: WCAG contrast ratios (4.5:1 body / 3:1 large) and their applicability to games; console readability guidance]`.
- **Never colour alone** — pair every colour-coded state with shape, icon, position, or text; support colourblind-safe palettes (deutan/protan/tritan).
- **Reduce-motion and flash safety** — an option to damp camera shake, parallax, and heavy motion.

### Audio / hearing
- **Captions and subtitles** — dialogue and meaningful non-speech audio; sized, backed for contrast, with speaker labels where it matters.
- **A visual channel for every critical audio cue** — anything a player must react to that is signalled by sound also has a visual (or haptic) form. (Audio itself is client-side: `guides/audio.md`.)
- **Independent volume mixes** — master / music / SFX / dialogue / ambience separable.

### Cognitive
- **Clear language and consistent interactions** — the same action works the same way everywhere; no genre-literacy assumed in an all-ages product.
- **Onboarding that teaches** rather than assuming — the first-time experience is a designed teach (cross-ref `guides/level-design.md` teach→test→twist; validate with `guides/playtesting.md`).
- **Reduce unnecessary time pressure and memory load**; let the player check information again rather than memorise it.

## Photosensitivity — a safety line, not a preference
Rapid, high-contrast flashing can trigger seizures. Flashing content must respect photosensitivity limits `[verify — web pass: the flash thresholds — general/red-flash guidance of ≤3 flashes per second and safe-area rules; tools like the Harding test]`. This is a hard safety requirement, not an option to expose — flag any effect that risks it for removal or redesign, and coordinate with `vfx-artist`.

## Standards & platform requirements
Check work against a recognised framework and cite it:
- **Game Accessibility Guidelines** — tiered basic / intermediate / advanced; a practical checklist to target by tier `[verify — web pass: current GAG tier contents]`.
- **Platform accessibility requirements** — consoles increasingly mandate specific features for certification; treat these as ship-blocking, not optional `[verify — web pass: current console accessibility cert requirements per target platform]`.
- **WCAG** where UI is web-like — a reference for contrast and text, adapted to game context.

## QUALITY BAR
Accessible-by-design when:
- **Requirements captured at design time**, not raised post-build.
- **No critical information on a single channel** — colour, audio, and input all have redundancy.
- **Each channel's options present with accessible defaults** — remap, text scale, captions, reduce-motion, independent mixes.
- **Photosensitivity limits respected** across all content.
- **Checked against a cited standard/tier**, gaps filed as defects naming the guideline they fail.
- **Validated with real players** where possible (`guides/playtesting.md`), including players who rely on the options.

## COMMON FAILURE MODES
- **Bolt-on-too-late.** → raise requirements during design.
- **Colour-only / audio-only / one-input.** → redundant encoding across channels.
- **Option behind a bad default.** → offer the option *and* default well.
- **Conformance from memory.** → cite the standard/tier; don't assert.
- **Flashing ignored.** → hard safety line; flag and redesign.
- **Onboarding assumes genre literacy.** → teach explicitly; validate with new players.
- **Checkbox ticked, player still blocked.** → the check is wrong; audit what it measured (doctrine 9).

## CHECKLIST
**At design time (P1 principles):**
- [ ] Accessibility requirements captured for each player-facing system as it's designed.
- [ ] Every critical info piece has a second channel identified.
- [ ] Options list drafted (input remap, text scale, captions, reduce-motion, mixes) with default choices.
- [ ] Target standard/tier and platform cert requirements identified.

**During build:**
- [ ] Never colour alone; captions + visual cue for critical audio; no single required input.
- [ ] Contrast and text-size targets met; UI scalable.
- [ ] Photosensitivity checked on any flashing/high-motion effect.

**Dedicated pass (P3):**
- [ ] Every option implemented with an accessible default.
- [ ] Checked against the cited standard/tier; gaps filed with the guideline they fail.
- [ ] Validated with real players, including those using the options.
- [ ] Handed to QA/creative-review — not self-cleared.

## Sources
Grounded in recognised game-accessibility practice `[verify — web pass: Game Accessibility Guidelines (gameaccessibilityguidelines.com); Xbox/PlayStation accessibility guidelines & cert; AbleGamers/CVAA where applicable; WCAG 2.x contrast/text; photosensitivity (Harding) thresholds]`.
