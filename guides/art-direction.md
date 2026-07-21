# Guide — Art Direction method

> Read before authoring or judging any visual work. The core idea: **the look is a committed target grounded in reference, not a set of adjectives — and a piece is judged against that target by the same measurable rubric every time, so "off-style" is a defect with a name, not an opinion.**

This is the craft reference for `agents/art-director`. It gives the vocabulary and the rubric to answer *"is this good?"* in terms a builder can act on. When a review reads "make it cooler / warmer / nicer", the review has failed this guide.

## The failures this prevents
1. **Direction by adjective.** "Make it moody / gritty / cool" is unfalsifiable — the builder guesses, the reviewer reacts, and every pass is a fresh argument. A board points at a direction; an adjective does not. A mood board exists precisely to *"replace vague adjectives with concrete images"* and let everyone agree on the feel *"in a form you can point at instead of describe"* ([Storyflow, *What is a Mood Board*](https://storyflow.so/blog/what-is-a-mood-board-complete-guide); [VistaPrint](https://www.vistaprint.com/hub/mood-board-examples)).
2. **Silent drift.** The build creeps off-style one defensible asset at a time — each fine alone, incoherent as a whole. On large productions inconsistency *"impacts player immersion, slows down production through rework… and weakens a game's brand identity"* ([Console Creatures, *Style Guide Development*](https://www.consolecreatures.com/style-guide-development-game-visuals/)). Consistency is *"what players experience as polish."*
3. **"Cool but off-pitch."** Technically competent work that is emotionally wrong for *this* game. Craft quality and pitch-fit are different axes; a piece can pass one and fail the other. This guide owns *on-style*; `creative-review` owns *on-pitch* against the vision doc. A review must say which axis failed.

## The one method — target a place, not an adjective
Ground every target in reference before a single asset is authored. *"Create a clear visual target before many artists start producing assets"* — direction that emerges mid-production is paid for in rework ([VSQUAD, *Game Art Direction*](https://vsquad.art/art-direction)). Three reference artifacts, in increasing specificity ([Neil Blevins, *Mood Boards, Design Packets and Callout Sheets*](http://www.neilblevins.com/art_lessons/mood_board_design_packet_callout_sheet/mood_board_design_packet_callout_sheet.htm)):

- **Mood board** — the *feel*. A curated wall of real places, films, photos that answers one question: *"what should this feel like?"* It points at a direction; it is **not** a draft of the asset.
- **Design packet / callout sheet** — the *specifics*. Each image annotated with what it is *for* — this roofline's rhythm, that concrete's wear pattern, this window's proportion. *"Each image should answer specific questions about form language, proportion, or material treatment instead of just looking visually appealing."*
- **Name every source.** *"If using reference from other films, games or from the internet, include the names… so that the artist can use that as a springboard."* A reference with no source is half a reference.

**Target a place, not an adjective:** "the light of a Lisbon side-street an hour before sunset" is a target; "warm and inviting" is a wish. The reference is the acceptance criterion — the build is judged against the board, not against the reviewer's mood that day (doctrine 2: the spec is committed before the build).

## The look-bible — this role's committed output
One document, written as-current (doctrine 12), that locks the visual target for a space or the whole world. It is the authority `qa-visual` and `creative-review` hold the build to. It must lock, concretely and with reference:

- **Palette** — the dominant/secondary/accent hues *as swatches*, with their allowed saturation and value ranges (see Color).
- **Value structure** — the intended notan: where the darks, lights and mid-tones live, and what the focal value contrast is (see Value & contrast).
- **Shape & silhouette language** — the vocabulary of forms and what they signal (see Style consistency).
- **Material logic** — the world's rules for how surfaces read: metal/wood/concrete/glass behaviour, wear, edge treatment. Materials must not contradict established world logic.
- **Stylisation level** — precisely where on the realism↔stylised axis this world sits, and the detail density that follows from it.
- **Lighting registers** — the committed day / night (etc.) setups (owned in build by `lighting-artist`; the bible sets their *target*, `guides/level-design.md` and the lighting agent own execution).

---

## PRINCIPLES

### Color
**Construct a limited palette in ratios, not a swatch pile.** The durable default is **60 / 30 / 10** — a dominant colour across ~60% of the frame (usually the quietest / most neutral, the visual "home base"), a secondary at ~30% for contrast and movement, an accent at ~10% that carries the focal spark ([Wix, *60-30-10 Color Rule*](https://www.wix.com/wixel/resources/60-30-10-color-rule); [FlowMapp](https://www.flowmapp.com/blog/qa/60-30-10-rule)). The ratio is what stops a frame reading as either monotonous or as noise where no colour registers.

**Harmony is a starting structure, not a rule.** Pick a relationship off the wheel deliberately ([Atmos, *Color Harmony*](https://atmos.style/glossary/color-harmony); [The Paper Mill Store](https://blog.thepapermillstore.com/color-theory-color-harmonies/)):
- **Complementary** (opposite) — high tension and contrast; powerful for a focal point, *"overwhelming"* in large doses at full saturation.
- **Analogous** (adjacent) — low tension, naturally cohesive; the safe choice for backgrounds and calm spaces.
- **Triadic** (120° apart) — vibrant and balanced, but *"requires careful control of saturation and lightness"* or it reads loud and toylike.

**Saturation is a budget, spent on the focal point.** *"Fully saturated colours at equal lightness rarely produce a practical design"* ([Atmos](https://atmos.style/glossary/color-harmony)). The discipline: desaturate the field, reserve your highest chroma for where you want the eye. A frame that is saturated everywhere has no focal point — saturation, like brightness, is a form of contrast, and contrast spent everywhere is spent nowhere.

**Temperature is measured, and it is storytelling — this guide is its home** (`guides/lighting.md` links here for the scale and psychology, and owns only the execution — matching temperature to a physical source, warm-key/cool-fill as a depth cue). Colour temperature runs the Kelvin scale — **~1800–3200K reads warm/amber** (comfort, intimacy, nostalgia), **~5500–9000K reads cool/blue** (tension, distance, the clinical) ([Fiveable, *Color Temperature*](https://fiveable.me/film-and-media-theory/key-terms/color-temperature); [NumberAnalytics](https://www.numberanalytics.com/blog/the-art-of-color-temperature-in-film-lighting)). Two rules follow: **consistency** of temperature holds continuity across a space, and **deliberate warm/cool contrast** adds depth and psychological weight — a warm key against a cool ambient is the oldest depth cue there is. Specify the target register in Kelvin, not as "warmish".

### Value & contrast
**Value does the structural work; colour decorates it.** Squint a frame down to two values (pure black / pure white) — its **notan** — and the composition either reads or it doesn't. Notan is *"the underlying value structure… the design or pattern created by the placement of lights and darks,"* and it must read *"both up close and at a distance"* ([Draw Paint Academy, *Notan*](https://drawpaintacademy.com/notan/); [Virtual Art Academy](https://www.virtualartacademy.com/notan/)). If the two-value reduction is busy and elements are indistinguishable, the composition is wrong — *"switch elements around until the design… appears more clear."*

**Group values into families; kill the mid-tone soup.** The most common readability failure is *"too much information… cluttered and less readable"* — everything drifting to a similar mid-value so nothing separates ([Realism Today, *Value Studies*](https://realismtoday.com/value-studies-mastering-notan-digital-painting/)). Merge similar values into big shapes, reduce the count of distinct value masses, and reserve the **widest value contrast for the focal point** — the eye goes to the point of greatest contrast first. A frame with strong black/white anchors and controlled mids reads instantly; a frame of grey-on-grey is muddy regardless of how good the colour is.

### Composition & visual hierarchy
**Every frame leads the eye on a deliberate path to a focal point.** Focal points are *"visual anchors that instantly draw attention, guiding viewers through your work in a deliberate sequence"* ([InklingNest, *Focal Point*](https://inklingnest.com/focal-point-in-art)). The tools:
- **Rule of thirds / power points.** The eye lands on the four intersections of the 3×3 grid; placing the focal element there reads more naturally than dead-centre ([Digital Photography School](https://digital-photography-school.com/rule-of-thirds/); [Linearity](https://www.linearity.io/blog/rule-of-thirds/)). A guideline to use deliberately and break deliberately — never by accident.
- **Leading lines.** Lines (a street, a rail, a shaft of light) *"guide the viewer's eye… toward key focal points"* — a visual journey with a destination.
- **Depth layering — foreground / midground / background.** Depth is built by putting something of interest in each layer, *"ideally in a composition that leads the eye from one to another"* ([SLR Lounge](https://www.slrlounge.com/foreground-middle-ground-and-background-in-photography/); [Expert Photography](https://expertphotography.com/foreground-middleground-background)). A flat frame is one that lives in a single plane. A foreground frame (an arch, foliage, a silhouette) also sets scale and pulls the viewer in.
- **Silhouette reading.** Read the frame as flat black shapes against the sky: focal masses and landmarks must be distinct, recognisable silhouettes with a clear hierarchy — this is the single strongest test of whether shape language is working (and it is the fourth view of the `qa-visual` battery, `guides/level-design.md`).
- **Negative space.** The quiet areas are not waste — they frame the focal point and give the eye somewhere to rest. A frame packed corner-to-corner has no hierarchy.

### Reading a captured frame critically
When judging a screenshot, read it in this fixed order — surface the first failure, don't skip to the pretty part:
1. **Notan first.** Mentally desaturate to two values. Is there a clear light/dark structure, or mid-tone soup? Is the widest contrast *at* the intended focal point, or scattered?
2. **Focal point.** Where does the eye go first? Is that where it should? Is there exactly one primary focus, or does the frame fight itself with three?
3. **Palette.** Sample it: does it hold the 60/30/10 target? Is chroma reserved for the focus, or sprayed everywhere? Is the temperature the specified register?
4. **Depth.** Are foreground/midground/background all doing work, or is it flat?
5. **Silhouette & shape.** Flat-black test: do the key masses read, in the world's shape language?
6. **On-style, then on-pitch.** Does it match the look-bible (this role)? Only then, is it right for the game (`creative-review`)?

**Trust the frame the player will see.** Judge from the saved, correctly-exposed capture in the intended register — a blown-white or crushed-black frame makes value and seating unjudgeable, and is itself a defect to bounce, not a frame to squint through (`guides/level-design.md`, capture discipline). And when the owner's eye disagrees with a green check, the check is wrong (doctrine 9).

### Style consistency — the on-style rubric
"On-style" is not a feeling. Judge a piece against the look-bible on each axis, and name the axis that fails ([VSQUAD](https://vsquad.art/art-direction); [Console Creatures](https://www.consolecreatures.com/style-guide-development-game-visuals/); [RocketBrush, *3D Art Styles*](https://rocketbrush.com/blog/exploring-3d-art-styles-for-games-a-guide-to-the-most-popular-types)):

- **Shape language.** Does it use the world's vocabulary of forms? Round/soft reads safe and friendly; sharp/angular reads threatening or unstable — shape *communicates*, and a piece whose shapes contradict the intended feel is off-style even if beautifully made ([RocketBrush, *Character Art Styles*](https://rocketbrush.com/blog/the-ultimate-character-art-style-guide-for-artists-and-developers)).
- **Material logic.** Do surfaces obey the world's rules — the same metal, concrete, glass behaviour, wear and edge treatment as everything around them? Semi-realistic work *"keeps enough believable structure, proportions and material logic to feel grounded"* while simplifying deliberately ([SunStrike, *Realism vs Stylization*](https://sunstrikestudios.com/en/blog/game_art_visual_direction/)).
- **Stylisation level.** Is it at the *same* point on the realism↔stylised axis as its neighbours? A photoreal prop in a stylised world (or the reverse) is the loudest possible inconsistency. Realism vs stylisation is a *commitment*, not a slider to nudge per asset.
- **Detail density.** Does its level of detail/noise match the target? Uniformly high detail is not richness — it flattens hierarchy into noise (see failure modes). Detail should cluster at focal points and rest elsewhere.
- **Palette & value.** Does it live inside the bible's swatches and value structure, or has it introduced a hue/chroma/value that nothing else uses?

---

## QUALITY BAR
A visual deliverable is *good* when:
- It has **one clear focal point**, and the eye is led to it by value contrast, colour, and composition — not left to wander.
- Its **notan reads** at a squint: grouped value families, focal contrast at the focus, no mid-tone soup.
- Its **palette holds a deliberate ratio and harmony**, chroma is reserved for the focus, and temperature matches the specified register.
- It has **depth** — foreground, midground, background each contributing.
- Its **silhouettes read** as distinct shapes in the world's shape language.
- It is **on-style on every rubric axis** — shape, material, stylisation level, detail density, palette — indistinguishable in origin from its neighbours.
- It **matches a named reference**, not a remembered adjective.
- (Then, separately, `creative-review` confirms it is **on-pitch**.)

Anything short of this is bounced with the *specific* axis named and, where possible, the reference it should have hit.

## COMMON FAILURE MODES
- **Direction by adjective.** No reference behind the target. → Refuse to brief or judge until a reference exists. The board is the spec.
- **No focal point.** The eye has nowhere to land, or three places at once. Everything is equally lit / equally saturated / equally detailed. → Establish one focus; subordinate the rest with value, chroma, and detail.
- **Muddy values / mid-tone soup.** Everything drifts to a similar mid-value; nothing separates at a squint. → Group into value families; push the darks and lights; widen focal contrast.
- **Saturation sprayed everywhere.** Full chroma across the whole frame, so no colour reads as special and the eye can't rest. → Desaturate the field; spend chroma at the focus.
- **Inconsistent palette / temperature.** A piece introduces a hue, chroma, or Kelvin the world doesn't use; adjacent spaces disagree on warm/cool. → Pull it back inside the bible's swatches and register.
- **Flat frame.** One depth plane, no foreground, no layering. → Add a foreground element; make midground and background each do work.
- **Detail-noise.** Uniformly high detail mistaken for richness — it flattens hierarchy and buries the focal point. → Cluster detail at the focus; let the rest rest.
- **Unmotivated / incoherent style.** Shape language, material logic, or stylisation level contradicts the world — a photoreal prop in a stylised scene, sharp menace where the world is soft. → Bounce on the specific rubric axis; "crude" never excuses *unmotivated* (a fast pass can still be coherent).
- **"Cool but off-pitch."** Genuinely well-crafted, wrong for *this* game. → This guide can pass it on-style; `creative-review` must still judge it on-pitch. Say which gate it failed.
- **Judging from a bad frame.** Blown/crushed/wrong-register capture, or a single cherry-picked hero angle. → Reject the frame, not the work; require a correctly-exposed capture in the intended register, multi-view.

## CHECKLIST
Against the committed look-bible + the named reference:
- [ ] **Reference exists** and is named — the target is a place, not an adjective.
- [ ] **Notan reads** at a two-value squint; value families grouped; **no mid-tone soup**.
- [ ] **One focal point**, and the widest value/chroma contrast sits on it.
- [ ] **Eye is led** — leading lines / thirds / framing point at the focus; negative space gives rest.
- [ ] **Palette** holds the dominant/secondary/accent ratio and chosen harmony; **chroma reserved for the focus**.
- [ ] **Temperature** matches the specified Kelvin register; adjacent spaces are consistent (or deliberately contrasted).
- [ ] **Depth**: foreground / midground / background each contribute.
- [ ] **Silhouettes** read as distinct shapes in the world's shape language.
- [ ] **On-style** on every axis: shape language · material logic · stylisation level · detail density · palette.
- [ ] **Capture is trustworthy**: correct exposure, intended register, multi-view — not one hero angle.
- [ ] **Verdict names the axis**: pass, or bounce with the *specific* failure mode and the reference it should have hit.
- [ ] **On-pitch is `creative-review`'s call** (fresh) — this gate sets the target it uses; it does not replace it.

> This gate is fast but never skipped — including on crude or throwaway-ish work. "Crude" excuses low fidelity; it never excuses an absent focal point, a broken value structure, or an unmotivated style. A quick pass is still a coherent one.
