# Guide — Localization & culturalization method

> Read before authoring player-facing text or a text layout. The core idea: **make the game translatable from day one, and translate it once the content is stable — externalize every string, build sentences that survive other grammars, and prove layouts under expansion before a translator is ever paid.** Localization is cheap to design in and brutally expensive to retrofit.

## The failures this prevents
1. **Hardcoded strings.** Text baked into code/widgets as literals, invisible to the pipeline — discovered at translation time when someone must hunt every one by hand. The single most common and most expensive loc defect.
2. **English-shaped sentences.** Strings glued from fragments, or assuming English word order, plurals, and gender — grammatically broken in most target languages and unfixable without re-authoring.
3. **Layouts that only fit English.** Fixed-width UI that clips German, breaks on CJK, or can't render right-to-left — found after art-lock, when the fix is a re-layout.
4. **Translating a moving target.** Paying to translate strings that are still changing, then paying again each time they change.

## PRINCIPLES
- **Every player-facing string is externalized.** It lives in a localization source (UE `FText` / string tables), never a hardcoded literal or an `FString`. If a player can read it, the pipeline must own it.
- **Never concatenate translatable fragments.** Word order, gender, and agreement differ by language; build sentences from **format strings with named arguments**, never by gluing pieces at runtime.
- **Design for text expansion.** Translated text is routinely longer than English; layouts flex, wrap, or truncate gracefully — never clip. Prove it with pseudo-localization before real translation.
- **Grammar is data, not code.** Plurals, gender, ordinals, dates, numbers, currency — handled by the pipeline's rules per locale, never `if (n == 1)` or a hardcoded format.
- **Context travels with the string.** A translator seeing "Open" can't tell a verb from a state; every string ships with a note on where and how it's used. A string with no context is a mistranslation waiting to happen.
- **Externalize continuously; translate late.** Externalization is a day-one authoring habit; translation waits until content churn settles (Phase 3) so you pay once.
- **Culturalization is surfaced, not decided.** What won't travel — symbols, gestures, colours, maps, names, sensitive themes — is flagged for the owner; the change is owner-reserved.

## The pipeline — extract → translate → import → build
The loop that lets translation iterate without a recompile `[verify — web pass: exact UE 5.8 localization dashboard / gather-text commandlet workflow, target/manifest/archive/LocRes file structure]`:
1. **Gather** — the pipeline scans for translatable text (`FText`, string tables) and produces a manifest of every string + its context. A string that doesn't appear here is hardcoded — fix it.
2. **Translate** — the string set (with context notes) goes to translators; translations return keyed to the source.
3. **Import** — translations are compiled into the localized data the runtime loads per locale.
4. **Build & verify** — a localized build is produced and checked for missing, clipped, or fallback-to-source strings.

Run **gather + pseudo-loc regularly during development**, not once before ship — it's how you catch a newly-hardcoded string the day it's added, cheaply.

## Pseudo-localization — the free early test
Before any real translation, generate a **pseudo-locale**: pad each string (+~40%), swap in accented/wide characters, and bracket it (`[!!! Ëxpändéd tëxt !!!]`). Play the game in it. This catches, for free:
- **Hardcoded strings** — anything still in plain English didn't go through the pipeline.
- **Text-fit failures** — anything clipped, truncated, or overflowing under expansion.
- **Concatenation** — glued sentences show their seams.
- **Encoding/font gaps** — missing glyphs for non-Latin scripts.

## Text-fit & layout (with `guides/ui-ux.md`)
UI layout is owned by `guides/ui-ux.md`; loc adds the constraints it must satisfy:
- **Assume ~30–40% expansion** for typical UI text (short strings far more — a 5-char English label can triple), and plan for CJK (denser, taller line needs) and RTL scripts `[verify — web pass: standard expansion-ratio table by source-string length; RTL/bidi support scope for the target locales]`.
- Layouts **flex or truncate gracefully with a tooltip/overflow**, never hard-clip. Fixed-width text boxes are a defect.
- No text baked into textures/materials that a player reads — it can't be localized without re-authoring the asset.

## Culturalization — beyond translation
Translation makes text readable; culturalization makes content *acceptable* in a market. Flag for the owner (never decide):
- Symbols, gestures, colours with cultural loading; religious/political references; maps and territorial depictions; real-world names; age/content-sensitive themes.
- Raise these **early** — a culturally unsafe asset baked deep into content is costly to pull. Coordinate with `compliance-advisor` where a market has legal content rules.

## QUALITY BAR
Localization-ready when:
- **Zero hardcoded/`FString` player-facing strings** — gather manifest accounts for all of them.
- **No runtime concatenation of translatable fragments** — format strings with named args throughout.
- **Pseudo-loc build passes** — nothing clipped, missing, or falling back to source; non-Latin glyphs render.
- **Every string has translator context.**
- **Plurals/gender/dates/numbers/currency** go through locale rules, not hardcoded English.
- **Culturalization risks surfaced** to the owner.
- **Translation happens on stable content**, not mid-churn.

## COMMON FAILURE MODES
- **Hardcoded string.** → `FText` + string table; catch it with a regular gather + pseudo-loc.
- **Glued sentence.** → format string with named arguments; never concatenate.
- **Clipped layout.** → design for expansion; prove with pseudo-loc; flex/truncate, never hard-clip.
- **English grammar assumed.** → locale rules for plural/gender/format.
- **No translator context.** → annotate every string; ambiguous source = mistranslation.
- **Text in a texture.** → externalize; no baked player-readable text.
- **Translating too early.** → externalize continuously, translate once content is stable.
- **Deciding a culturalization change.** → surface to the owner; it's owner-reserved.

## CHECKLIST
**Authoring (continuous, from P1):**
- [ ] Every new player-facing string is `FText` / string-table, with context note.
- [ ] Sentences use format strings with named arguments — no concatenation.
- [ ] Plurals/gender/dates/numbers/currency use locale handling.
- [ ] No player-readable text baked into textures/materials.

**Periodic verification:**
- [ ] Gather run; manifest reviewed for newly-hardcoded strings.
- [ ] Pseudo-loc build played; clipping, missing glyphs, and seams caught and fixed.
- [ ] Culturalization risks logged and surfaced to the owner.

**Before translation (P3):**
- [ ] Content churn settled; string set stable.
- [ ] Context-annotated string set prepared for translators.
- [ ] Target locales, scripts (incl. RTL/CJK), and fonts confirmed.
- [ ] Localized build verified: no fallback-to-source, no fit breaks.

## Sources
Grounded in standard game-localization practice and the UE localization system `[verify — web pass: UE 5.8 Localization Dashboard docs and gather-text pipeline; IGDA Localization SIG best practices; standard text-expansion ratios; culturalization guidance (e.g. Chandler & Deming, The Game Localization Handbook)]`.
