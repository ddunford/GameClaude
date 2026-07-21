# Guide — Lighting craft

> Read before authoring or revising any level's lighting. The core idea: **light is not switched on, it is *motivated* — every light in the scene traces to a source the player can believe, and it is shaped (key / fill / rim), coloured, and exposed to lead the eye and hold a register, then verified from more than one flattering angle by a fresh reviewer.**
>
> This guide owns the **craft** — the artistic principles, engine-agnostic. The **engine mechanics** (sky is scene-global, spatial night-under-day-sky, the empirical exposure-bias numbers, PLA-drops-lights → emissive, the capture rig) live in **`guides/unreal-engine.md §5`** and are cross-referenced, never duplicated here.

## The failure this exists to prevent

Bare point-lights **floating in the middle of a street with no physical source** — a glow hanging in open air, lighting nothing the player could attribute to a lamp, window, sign, or sky — read as broken even when the exposure is locked, the contact shadows are present, and no highlight blows. Every other rule can pass and the scene is still wrong, because the first rule outranks them all: **a light with no source is a defect, however technically clean.** That is Principle 1, and it is the headline.

---

## PRINCIPLES

### 1. Motivated lighting — every light has a plausible source (the headline)
Before you place a light, name what emits it: **the sky/sun/moon**, or a **practical** in the world — a lamp, a window, a neon sign, a doorway spill, a fire, a screen, a vehicle headlight. If you cannot name the source, you do not place the light. The audience must never wonder *where is that coming from* — motivated light is light "logically created within the world" of the scene, and its whole job is to keep the viewer immersed rather than noticing the rig. `[web]` [StudioBinder — Motivated Lighting](https://www.studiobinder.com/blog/what-is-motivated-lighting-in-film/) · [No Film School](https://nofilmschool.com/motivated-lighting)

- **A visible fixture may justify several in-engine lights.** One street lamp can motivate a bright spot at the bulb, a soft pool on the ground, and a faint bounce on the wall behind — that is efficiency, not a violation. What is forbidden is the *reverse*: an in-engine light with no fixture anywhere. `[web]` [The Level Design Book — Lighting](https://book.leveldesignbook.com/process/lighting)
- **A hanging source is authored WITH its support, in the same pass.** A lantern, sign, or bulb that emits light needs its wire, cord, chain, bracket, or pole modelled alongside it — a bare emissive sphere hanging in mid-air with no visible means of support is the floating-source defect all over again, *even when a nearby fill light is perfectly motivated*. The glow is not the source; the **fixture** is, and a fixture the player sees suspended from nothing reads as broken. Place the support with the light, never as a later polish step that gets forgotten.
- **Place the fixture (or the sky/occluder) first, then the light that imitates it.** This is how film does it — choose the source, then add off-camera units that mimic its direction, colour, and intensity so you can control exposure without breaking the illusion. `[web]` [FilmDaft — Motivated Lighting](https://filmdaft.com/what-is-motivated-lighting-definition-examples/)
- **Inside a Packed Level Actor, the source is emissive, not a light** — PLAs silently drop lights, so a window-spill or neon inside one is authored as an emissive material. The principle is unchanged (there is still a visible source); only the mechanism differs. See `guides/unreal-engine.md §5`.
- **This holds for crude spikes too.** "Crude" excuses low fidelity — a rough mesh, an unpolished bounce — it never excuses an unmotivated light. A whitebox lamp-post with a cheap light is motivated; a glow in mid-air is not.

### 2. Think in key / fill / rim — shape, don't just illuminate
Even a whole environment is read as a subject against a background. The three-point vocabulary is how you give it form:

- **Key** — the dominant light, the one that defines the primary direction and the shadows. It is *motivated* (the sun, the main window, the sign). Everything else is relative to it.
- **Fill** — a softer, dimmer light (or bounce/skylight) opposite the key that lifts the shadows so they read as detail, not black holes. The **key:fill ratio sets the mood**: a low ratio (fill near the key, ~2:1) is even and open; a high ratio (fill much dimmer, 8:1 and beyond) is high-contrast, dramatic, film-noir. Fill is typically 25–75% of key for cinematic looks, higher for a flat commercial evenness. `[web]` [StudioBinder — Three-Point Lighting](https://www.studiobinder.com/blog/three-point-lighting-setup/) · [Fiveable — Three-Point Lighting](https://fiveable.me/advanced-cinematography/unit-2/three-point-lighting/study-guide/e8LmJZ9P7j2gicjA)
- **Rim / kicker / backlight** — from behind, catching the edge to **separate the subject from the background** and add depth. In an environment this is the low sun catching a roofline, a sign backlighting a figure in a doorway, moonlight edging a wall against a dark sky. Without separation, foreground and background merge into one flat mass. `[web]` [MasterClass — Three-Point Lighting](https://www.masterclass.com/articles/what-is-three-point-lighting-learn-about-the-lighting-technique-and-tips-for-the-best-three-point-lighting-setups)

### 3. Colour temperature (Kelvin) and warm/cool contrast
The **Kelvin scale and the warm/cool psychology it carries are owned by `guides/art-direction.md` (Color)** — read it there for the ranges and what each register *means*. Lighting's job is to put that scale onto real sources and to execute the contrast:

- **Match the temperature to the register and to the source.** A sodium street lamp is warm-orange; a fluorescent office is greenish-cool; moonlight is *rendered* cool (see the register table); a neon sign is whatever colour it is and spills that colour onto nearby surfaces. Getting the temperature wrong for the source breaks the motivation from Principle 1.
- **Never light monochrome — warm key against cool fill.** A scene lit at one temperature is dead. The strongest, most-used move is **warm key against cool fill** (or the reverse): warm practicals against a cool sky, warm interior against cool night. This mirrors nature — warm sunlight vs. cool open-sky shadow — and it manufactures depth and separation for free. `[web]` [Rubbrband — Color Temperature in Cinema](https://www.rubbrband.com/blog/color-temperature-cinema) · [NumberAnalytics — Color Temperature in Film Lighting](https://www.numberanalytics.com/blog/the-art-of-color-temperature-in-film-lighting)

**Register cheat-sheet (starting points, tune by eye):**

| Register | Key source & temp | Fill / ambient | Feel |
|---|---|---|---|
| **Day** | Sun, ~5000–6500K, hard | Cool sky bounce, bright | Open, legible, neutral |
| **Dusk / golden hour** | Low sun, ~2500–3500K warm, long shadows | Deep-blue sky fill | Romantic, transitional, high warm/cool split |
| **Night (exterior)** | Moon *rendered* cool (physically ~4100K neutral, tinted blue by cinema convention) + warm practicals | Very low cool ambient — *lit*, not black | Moody, pooled, high-contrast |
| **Interior** | Windows (cool daylight) or lamps (warm) | Bounce off walls/ceiling | Intimate; temperature tells you day-outside vs. lamp-lit |

### 4. Exposure discipline and dynamic range
- **Manual exposure, locked per register — never auto.** Auto-exposure re-balances to whatever is in frame and drifts the whole look as the camera moves. Lock it. (The engine specifics live in two homes, with **opposite sign conventions** — don't conflate them: the **register**'s manual-exposure `ExposureCompensation` — empirical, not EV, *positive = brighter* — is in `guides/unreal-engine.md §5`; the **capture tool**'s `CaptureTools.exposure_bias` — *more-negative = brighter* — is in `guides/level-design.md`.)
- **No blown highlights, no crushed blacks.** A blown highlight is lost information — pure white with no detail; a crushed black is the same at the other end. Expose so the **range you care about lands between them**: bright surfaces stay just below clipping, shadows retain readable detail. `[web]` [PetaPixel — Inverse-Square Law of Light](https://petapixel.com/inverse-square-law-light/)
- **Locked ≠ crushed.** A "night" register locked so dark the scene disappears is a defect, not a mood — a dark scene the player cannot read is exactly what the owner calls out. Night is *lit at night*: pooled practicals, cool moon fill, and enough ambient that geometry, bases, and the critical path still resolve.
- **Dark albedo defeats every light.** If diffuse textures are too dark, bounce is faint no matter how bright the lights — keep main diffuse roughly 50–100% brightness so GI has something to carry. `[web]` [The Level Design Book — Lighting](https://book.leveldesignbook.com/process/lighting)

### 5. Global illumination, bounce, and ambient fill — nothing crushes
- **Every surface facing away from a light still gets *some* light.** In reality that is bounce (GI) and sky ambient; in-engine it is Lumen bounce plus a **skylight**. A scene with a sun and no skylight/ambient has pure-black shadow sides — the single-directional-light-can't-light-an-elevation failure in `guides/unreal-engine.md §5` is exactly this.
- **Add a skylight / ambient fill early** as the baseline that guarantees legibility, then shape *on top* of it with key and practicals. The skylight is your global fill (Principle 2). `[web]` [Sinfull Studios — Lighting with Lumen](https://sinfullstudios.com/unreal-engine-lumen-environment-lighting-guide/)
- **Warm key + cool sky-bounce = a motivated look for free** — a low warm sun with cool sky fill at the horizon is a complete, believable rig before you add a single practical. `[web]` [SDLC — Lighting Techniques in Unreal](https://sdlccorp.com/post/lighting-techniques-in-unreal-engine-for-stunning-visuals/)

### 6. Atmosphere — fog and volumetrics as glow and depth
- **Volumetric fog makes light visible in the air** — beams, shafts, god rays where light passes through fog/dust/smoke. It reads as depth and mood, and it turns a motivated source into a *felt* one (a shaft from a window, a cone under a street lamp, neon haze). `[web]` [game-developers.org — Volumetric Lighting](https://game-developers.org/volumetric-lighting-explained) · [Language of Lighting — Volumetric Lighting in Games](https://languageoflighting.com/lighting-design-concepts/volumetric-lighting/)
- **Fog also separates depth planes** — distant geometry fades, near geometry stays crisp, and the eye reads the space as deep. A little atmospheric fog is one of the cheapest upgrades from "flat" to "atmospheric."
- **Light shafts guide the player** — a shaft from a doorway or window is both mood and wayfinding; games use them to pull the eye toward the way forward and to signal danger. `[web]` [game-developers.org — Volumetric Lighting](https://game-developers.org/volumetric-lighting-explained)

### 7. Believable falloff — the inverse-square law
Real light falls off with the **inverse square of distance**: double the distance, quarter the intensity. `[web]` [Westcott — Inverse Square Law](https://help.fjwestcott.com/en-US/what-is-the-inverse-square-law-2219558)

- **A close source has fast falloff** (bright hotspot, rapid drop to shadow — dramatic, high contrast); **a distant source has gradual falloff** (even, soft). Use this deliberately: a lamp close to a wall makes a tight bright pool; the sun, effectively infinitely far, is even across the whole scene. `[web]` [Great Big Photography World — Inverse Square Law](https://greatbigphotographyworld.com/inverse-square-law/)
- **A light with a hard cutoff radius and no falloff reads as fake** — one of the tells of an unmotivated light. Give point/spot lights physical-plausible falloff and an attenuation radius that matches what the fixture could actually throw.

### 8. Lead the eye — contrast is the tool, readability is the job
The eye goes **involuntarily to the brightest point and to the point of highest contrast** — this is consistent across all viewers. Lighting is therefore how you compose attention. `[web]` [Smile Lighting — Visual Hierarchy Through Light](https://www.smilelighting.com/2026/05/02/visual-hierarchy-through-light-how-to-guide-the-eye-and-create-a-spatial-narrative/) · [Neil Blevins — Contrasts in Composition](http://www.neilblevins.com/art_lessons/composition_contrasts/composition_contrasts.htm)

- **Put your strongest contrast on what matters** — the door, the exit, the landmark, the interactive object. Brightly lit doorways tell the player where the flow goes; secondary spaces get dimmer, less-focused treatment to build hierarchy. `[web]` [The Level Design Book — Lighting](https://book.leveldesignbook.com/process/lighting)
- **Do not waste your darkest-dark / lightest-light on an unimportant corner** — high contrast anywhere pulls the eye there whether you meant it or not. Keep high contrast in focal areas; keep dead areas low-contrast. `[web]` [Neil Blevins — Contrasts in Composition](http://www.neilblevins.com/art_lessons/composition_contrasts/composition_contrasts.htm)
- **Work in passes, not all at once:** global lights → wayfinding / critical path → gameplay / interaction cues → detail & mood. This keeps readability the priority and mood the polish, not the reverse. `[web]` [The Level Design Book — Lighting](https://book.leveldesignbook.com/process/lighting)

### 9. Performance-aware light counts
Every dynamic shadow-casting light has a cost. **Motivation naturally limits count** — you place lights where sources are, not everywhere. Prefer one well-placed shadow-caster over many; turn shadow-casting *off* on fill and bounce-fake lights (games break physics deliberately for cost and drama — a fill light that casts no shadow is normal and correct). `[web]` [The Level Design Book — Lighting](https://book.leveldesignbook.com/process/lighting) · [80.lv — Lighting for Games in Unreal](https://80.lv/articles/how-to-set-up-lighting-for-games-in-unreal-engine-part-1)

---

## QUALITY BAR

A lit scene is at bar when:
- **Every light traces to a nameable source** — sky/sun/moon or a visible practical (or emissive, inside a PLA). Nothing floats in open air.
- There is a **clear key**, a **fill that lifts shadows to readable** (not black, not flat), and **rim/separation** where foreground would otherwise merge with background.
- **Warm/cool contrast is present and motivated** — the scene is not one flat temperature, and each temperature matches its source and register.
- **Exposure is manual and locked**, tuned so **no highlight clips and no shadow crushes** — the full critical path, every base, and every corner are legible.
- **Ambient/skylight guarantees a floor of legibility** before shaping; **contact shadows sit at every base** so nothing appears to hover.
- The **register is deliberate and holds** (day / dusk / night / interior) and reads as that register from every verified view — a night is lit *at night*, not switched off.
- **Contrast leads the eye to what matters** (door, landmark, interaction); dead areas are low-contrast.
- **Verified from a top-down AND an eye-level walk** (both registers), from the **saved** level, by a **fresh reviewer** — never the builder, never one hero angle.

---

## COMMON FAILURE MODES

- **Unmotivated / sourceless light — the floating-light defect.** A light in open air; a glow with no fixture, window, sign, or sky behind it; or a hanging fixture (lantern/sign/bulb) whose support — wire, cord, chain, pole — was never modelled, so the emissive source itself floats. The scene can pass every exposure and shadow check and still be broken. *This is the #1 failure; if you cannot name the source, delete the light — and if the source hangs, give it its support in the same pass.* (Principle 1.)
- **Flat / no-key lighting.** Even illumination from everywhere, no dominant direction, no shadows — nothing has form, the scene reads as a render preview, not a place. (Principle 2.)
- **Blown highlights.** Clipped-white surfaces with no detail — lost information, and a dead giveaway of an un-tuned or auto exposure. (Principle 4.)
- **Crushed blacks / a "night" you can't read.** Locked-dark to fake mood until geometry, bases, and the path vanish. Night must be *lit at night*. (Principle 4.)
- **Light leaks.** Light bleeding through walls/floors where it shouldn't — an occluder that doesn't seal, or thin walls dropping out of Lumen's distance field. Breaks the enclosure and the motivation. (See `guides/unreal-engine.md §5` for the thin-wall SDF and the sealing-occluder mechanics.)
- **Even / boring lighting with no focal contrast.** Technically fine, emotionally dead — no hierarchy, the eye has nowhere to go, the door and the dead corner are equally lit. (Principle 8.)
- **Wrong colour temperature for the mood or the source.** A warm scene that should be cold night; a "sunlit" interior lit at candle-warmth; a single flat temperature with no warm/cool contrast. (Principle 3.)
- **Fake falloff.** A hard light-radius cutoff, or a source that lights evenly regardless of distance — reads as engine, not world. (Principle 7.)
- **Too many shadow-casting lights.** Motivation ignored, lights sprayed everywhere, frame cost blown for no readability gain. (Principle 9.)

---

## CHECKLIST (before handing to `qa-visual`)

- [ ] **Every light has a named source** — sky/sun/moon or a visible practical (emissive inside PLAs). No floating lights. *(the headline gate)*
- [ ] There is a clear **key**; **fill** lifts shadows to readable; **rim/separation** where planes would merge.
- [ ] **Warm/cool contrast** present and each temperature matches its source + register.
- [ ] **Exposure is manual and locked** for this register; sweep-checked so **nothing blows out and nothing crushes**.
- [ ] **Skylight / ambient fill** in place as the legibility floor; **contact shadows at every base**.
- [ ] Register (day/dusk/night/interior) is **committed and switchable**, and a **night reads as lit-at-night**.
- [ ] **Atmosphere/fog** used where it adds depth or a motivated glow — not defaulted to zero, not overdone to soup.
- [ ] **Contrast leads the eye** to the door/landmark/interaction; dead areas kept low-contrast.
- [ ] Verified **top-down AND eye-level walk**, **both registers**, from the **SAVED** level.
- [ ] Handed to `qa-visual` → `art-director` → `creative-review` (fresh, judged in the correct register) — **never self-approved, never straight to the owner**.

---

## Engine cross-reference

The **how** in this engine lives in `guides/unreal-engine.md §5`, which owns and must be read alongside this guide for:
- Sky Atmosphere / Directional / Sky Light / fog are **scene-global** (one set per world); a Level Instance shares the global sky.
- **Night-under-a-day-sky is built spatially** — full enclosure + a sealing overhead occluder + a bounded manual-exposure `PostProcessVolume` + local lights.
- **Manual-exposure bias is empirical, not EV** — the measured working numbers for this project's rigs.
- **PLAs drop lights/Niagara** → author interior spill as **emissive material** or an external WP light actor.
- **Lighting Scenario levels** for baked day/night; animate the shared sun for dynamic Lumen day-night.
- The **capture/legibility rig** (key + opposing fill directional pair, shadow-casting off, + skylight; ortho capture; priming a cold SceneCapture) — needed so the multi-view battery can actually *see* the scene.

The rule: **this guide tells you what good lighting *is*; `§5` tells you what this engine will and won't *let you do* to achieve it.** When the two ever conflict on an engine fact, `§5` (source-cited) wins — raise a `[verify]` via `engine-verifier`.

---

## Sources
- StudioBinder — [Motivated Lighting](https://www.studiobinder.com/blog/what-is-motivated-lighting-in-film/) · [Three-Point Lighting](https://www.studiobinder.com/blog/three-point-lighting-setup/)
- No Film School — [Motivated Lighting](https://nofilmschool.com/motivated-lighting) · FilmDaft — [Motivated Lighting](https://filmdaft.com/what-is-motivated-lighting-definition-examples/)
- Fiveable — [Three-Point Lighting](https://fiveable.me/advanced-cinematography/unit-2/three-point-lighting/study-guide/e8LmJZ9P7j2gicjA) · [Color Temperature](https://fiveable.me/film-and-media-theory/key-terms/color-temperature)
- MasterClass — [Three-Point Lighting](https://www.masterclass.com/articles/what-is-three-point-lighting-learn-about-the-lighting-technique-and-tips-for-the-best-three-point-lighting-setups)
- Lumens — [Kelvin Colour Temperature Chart](https://the-edit.lumens.com/the-guides/understanding-kelvin-color-temperature/) · Rubbrband — [Colour Temperature in Cinema](https://www.rubbrband.com/blog/color-temperature-cinema) · NumberAnalytics — [Colour Temperature in Film Lighting](https://www.numberanalytics.com/blog/the-art-of-color-temperature-in-film-lighting)
- The Level Design Book — [Lighting](https://book.leveldesignbook.com/process/lighting)
- Sinfull Studios — [Lighting with Lumen](https://sinfullstudios.com/unreal-engine-lumen-environment-lighting-guide/) · SDLC — [Lighting Techniques in Unreal](https://sdlccorp.com/post/lighting-techniques-in-unreal-engine-for-stunning-visuals/) · 80.lv — [Lighting for Games in Unreal](https://80.lv/articles/how-to-set-up-lighting-for-games-in-unreal-engine-part-1)
- game-developers.org — [Volumetric Lighting](https://game-developers.org/volumetric-lighting-explained) · Language of Lighting — [Volumetric Lighting in Games](https://languageoflighting.com/lighting-design-concepts/volumetric-lighting/)
- PetaPixel — [Inverse-Square Law of Light](https://petapixel.com/inverse-square-law-light/) · Westcott — [Inverse Square Law](https://help.fjwestcott.com/en-US/what-is-the-inverse-square-law-2219558) · Great Big Photography World — [Inverse Square Law](https://greatbigphotographyworld.com/inverse-square-law/)
- Smile Lighting — [Visual Hierarchy Through Light](https://www.smilelighting.com/2026/05/02/visual-hierarchy-through-light-how-to-guide-the-eye-and-create-a-spatial-narrative/) · Neil Blevins — [Contrasts in Composition](http://www.neilblevins.com/art_lessons/composition_contrasts/composition_contrasts.htm)
