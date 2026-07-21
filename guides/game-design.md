# Guide — Game Design method

> Read before defining or balancing any system, loop, economy, or progression. The core idea: **you design the *rules* and let the *experience* emerge — so you name the intended feeling first, build the smallest loop that could produce it, prove it is fun in a spike, and keep every number in data where you can tune it. A system is done when its loop has been *felt*, its contract is committed, and its balance lives in a table — not when it compiles.**

## The two failures this prevents
1. **The un-felt loop.** A system argued into existence on paper — coherent, elegant, and dead in the hand. Fun is not deducible from a spec; it is observed. Trial-1's mechanics were reasoned about and never spiked, so nobody discovered they weren't fun until they were built. A loop you have not walked is a guess (doctrine 3).
2. **No authority, balance in code.** Building with no committed spec, so "unbalanced" or "not fun" is an opinion with nothing to hold the build to — and baking rates, costs, and curves into C++, so every tuning change is a rebuild and iteration dies. Balance you cannot change in a data table is balance you will not change.

## PRINCIPLES
The craft rules that hold across every system. The stages tell you *when*; these tell you *what good looks like*.
- **Design from the experience backward (MDA).** Name the intended **aesthetic** — the feeling — first; then the **dynamics** (behaviour in play) that produce it; then the **mechanics** (rules) that produce those. You build bottom-up (mechanics→dynamics→aesthetics); the player receives top-down (aesthetics first, rules only later). Design the feeling you want, not the rule you think is clever.
- **The loop is the unit of design, not the feature.** A mechanic that doesn't feed a repeating loop with a *reason to come back* is a toy, not a system. Every loop must close: **action → feedback → reward → motivation → repeat.**
- **Prove fun in a spike before production (doctrine 3).** Felt, not argued. A crude isolated prototype that answers "does this feel good to do?" beats any amount of paper reasoning, and it comes *before* the system enters the main build.
- **Interesting decisions, not busywork.** Sid Meier's test — a game is "a series of interesting decisions." If a step has an obviously-correct choice, no meaningful trade-off, or no consequence, it is friction, not gameplay. Design the decision, then the mechanic that frames it.
- **Design the system, not the outcome.** Set the rules and let the dynamics emerge; when the result is wrong, tune the *rule*, not the symptom. Scripting the outcome you wanted is the opposite of systems design and does not scale.
- **Design in data, not code.** Every rate, cost, budget, curve, and threshold lives in a data table / curve / data asset, tunable without a rebuild. Code reads the numbers; it never *is* the numbers.
- **The spec is the authority (doctrine 2).** A written contract — inputs, states, outputs, edge cases — committed before the build, so a defect is "doesn't match the spec," not an argument.
- **Fairness is a design constraint, not an afterthought.** Anti-exploit and no-pay-to-win are decided in the design, not patched after launch. Every client-reachable surface is hostile until proven (doctrine 11) — hand it to `security-reviewer`.
- **Design for a mix of motivations, not for yourself.** The audience is a spread of player types; a system that only rewards how *you* like to play starves most of your players.

## Stages — intent to handoff
0. **Intent.** Name the **aesthetic** this system serves (which of the ranked emotional beats, per `creative-director`). State the loop it feeds and the decision it frames. One paragraph, no mechanics yet.
1. **Loop on paper.** Sketch the loop(s): action → feedback → reward → motivation. Identify every source and sink, every input and state. Decide what nests inside what. No numbers yet — structure first.
2. **Spike (doctrine 3).** Build the crudest playable version *in isolation* — grey boxes, debug numbers, no art — that answers "is the core action fun to repeat?" Get it reviewed by `creative-director`. Iterate or discard. **The main build is never touched by unproven work.**
3. **Spec.** Write the committed system spec (below) — the contract an engineer builds from and QA checks against. Put first-pass numbers in a data table, not the spec prose.
4. **Tune.** Once built, balance against the metrics in data. Model the economy before trusting it (below). Playtest for exploits and dominant strategies.
5. **Handoff & gate.** The spec + tuning tables are the authority `gameplay-engineer` builds to, `security-reviewer` hardens, and `creative-review` judges. **You never sign off your own system's implementation** (doctrine 1).

## Loops — the unit of design
Games are built of nested loops on different timescales; a strong game layers several so each feeds the next. Design each explicitly and know which timescale it lives on:
- **Moment-to-moment (micro)** — seconds. The verb the player performs constantly: move, shoot, place, talk. This is where **game feel** lives (below); if it isn't satisfying alone, nothing built on it is.
- **Core loop** — the primary cycle the game *is*: the repeated activity that produces reward and pulls the player into the next iteration (fight→loot→upgrade; build→earn→expand).
- **Session loop** — a play session's arc: what a player sets out to accomplish in one sitting and the sense of a session well-spent when they stop.
- **Meta / retention loop** — days to months. The long goals — progression, unlocks, status, social ties, creations — that give a reason to return after the session ends.

**Every loop must close.** `action → feedback → reward → motivation → repeat`. A loop with no clear reward, or a reward that doesn't motivate the next action, is a loop players leave. Nesting is the point: a Hades run nests combat encounters (micro) inside a dungeon run (core) inside meta-progression unlocks (retention), and each layer reinforces the others. Name the nesting explicitly — an orphaned loop that feeds nothing is a dead end.

**In ElseCity:** the moment-to-moment is traversal and social presence; the core loop is *discover a door → experience the world behind it → return changed / richer*; the meta loop is the **creator economy** — build a world, attract visitors, earn, reinvest. The **door transition** is itself a designed beat (street hum → the world beyond), not just a level load.

## MDA — design from the experience backward
Three causally-linked layers (Hunicke, LeBlanc & Zubek):
- **Mechanics** — the rules and systems you author (the data and code).
- **Dynamics** — the run-time behaviour that emerges when players engage the mechanics.
- **Aesthetics** — the emotional response evoked in the player.

The designer builds **M→D→A**; the player experiences **A→D→M** (feeling first, rules noticed later). This asymmetry is the whole lesson: **a small mechanical tweak can transform the emotional experience**, and you cannot judge a mechanic except by the dynamics and feeling it produces in play. Name the target aesthetic from the "8 kinds of fun" so "fun" is specific, not vague: **Sensation, Fantasy, Narrative, Challenge, Fellowship, Discovery, Expression, Submission**. ElseCity leans **Fellowship, Expression, and Discovery** — design toward those, and check every system against which one it serves.

## Systems, not features — emergence and second-order effects
A **feature** does one scripted thing; a **system** is a set of rules that interact to produce outcomes you did not hand-place. Systems are how a small team builds a big space of experiences: the depth comes from **interaction**, not from content volume.
- **Emergent over scripted, where you can afford it.** Scripted moments are authored once and consumed once; systemic moments regenerate. But emergence is *harder to control* — it produces exploits and dominant strategies as readily as delight.
- **Design for second-order effects.** When two systems touch, ask what a player optimising each will do at the seam. Most exploits and most emergent joy live in these seams — economy × combat, crafting × trade, movement × stealth. Enumerate the interactions on paper; you will not think of them all, which is why you spike and playtest.
- **Tune the rule, not the symptom.** When a dynamic is wrong (one strategy dominates, a resource is worthless), change the underlying rate or rule and let the system re-settle. Patching the symptom (nerf this one number by hand every patch) means you never fixed the system.
- **Watch for the dominant strategy.** If there is one obviously-best way to play, the interesting decisions collapse. Balance is the art of keeping several strategies viable.

## Progression & difficulty — the flow channel
Engagement lives in Csíkszentmihályi's **flow channel**: challenge and skill rising together. Too much challenge for current skill → **anxiety** and rage-quit; too little → **boredom** and quiet churn. The player's skill climbs as they play, so a *flat* difficulty falls out of the channel in both directions over time.
- **Curve, don't spike.** Difficulty rises overall with a sawtooth — peaks and recoveries — never a flat line or a permanent climb. Alternate intensity with respite (this is the systems-side twin of level-design pacing).
- **Teach → test → twist.** Introduce a mechanic safely, confirm the player has it, then complicate it. Never hand a player a new ability without teaching it; teach through play, not text walls. Lower difficulty briefly when introducing something new, then raise it.
- **Power vs mastery — gate on the right one.** *Mastery* is player skill; *power* is character/account strength. Gate content on whichever the design intends, and be deliberate: gating a competitive surface on **power** (which can be bought or ground) rather than **mastery** is how pay-to-win and grind-walls sneak in.
- **In ElseCity:** power gates on progression, and **there is no pay-to-win in mixed-competition zones** (a settled rule). Progression is a curve of capability and access, tuned in data — not a wall priced in currency.

## Economy — faucets, sinks, and the value of a coin
An economy is a flow: **sources (faucets)** create currency/resources from nothing and inject them; **sinks (drains)** remove them permanently. Health is the *ratio* between them over time.
- **Every faucet needs a matching sink.** Faucets are effectively infinite and scale with player count and game age; unmatched, they cause **inflation** — the total currency grows, each coin buys less, and new players are priced out while savings evaporate. The classic failure is a rich faucet with no real sink.
- **Hard sinks vs soft sinks.** A **hard sink** destroys value permanently (repair costs, consumables, taxes/fees, premium purchases) — this is what actually fights inflation. A **soft sink** moves value between players without destroying it (a marketplace fee is hard; the trade itself is soft) — it does *not* reduce the money supply, it only redistributes it. Know which you are building; only hard sinks control inflation.
- **Make sinks worth spending on.** A sink players resent is a sink they route around. The best sinks are desirable (cosmetics, capability, status), so spending feels like progress, not tax.
- **Feedback loops set stability.** *Positive* loops amplify (the rich get richer — destabilising, good for creating swings and blowouts); *negative* loops dampen (costs that scale with wealth/progress — stabilising, good for keeping the economy in band). Choose them deliberately; an economy with only positive loops runs away.
- **Model before you trust.** Diagram the flow (sources, sinks, stocks, converters, feedback) and simulate it — on paper or in a tool like Machinations (Adams & Dormans) — *before* building. Inflation and starvation are visible in the model long before they are visible in production, and cheaper to fix there.
- **In ElseCity:** currency and inventory are **server-authoritative** — never trust the client with balances (doctrine 11). The **creator economy** is a two-sided market (creators earn, visitors spend); its faucets and sinks are a design surface, and every earning/spending endpoint goes to `security-reviewer`. UGC is **budget-capped in data** — the caps are an economy of complexity, tuned in tables, not code.

## Feedback & juice — from the design side
"Juice" is not just VFX polish the engineers add at the end — it is a **design responsibility**: the loop's `feedback` step. If cause→effect isn't legible, the player can't learn the system, and an unlearnable system isn't fun (Swink, *Game Feel*). This section owns *what* feedback each action needs and *why*; the technique catalogue that makes it *land* — hit-stop, screenshake, squash-and-stretch, camera kick, and the restraint ceiling on all of them — is the `game-feel` craft's (`guides/game-feel.md`).
- **Readability first.** Every action produces immediate, unambiguous feedback proportional to its importance. The player must always be able to answer "what did I just do, and did it work?" A system whose effects are invisible or delayed teaches nothing.
- **Specify the feel, don't leave it to chance.** The spec names the intended feedback for each action — what the player sees/hears/feels on success, on failure, on partial progress — so `gameplay-engineer`, `sound-designer`, and VFX build *to* it and QA checks *against* it. Feel is a spec line, not an accident.
- **Reward schedules — powerful and to be used honestly.** Fixed rewards are predictable and calm; **variable-ratio** rewards (uncertain payoff per action) are the most engagement-dense and the most habit-forming. That power carries an ethical line: for an all-ages audience, design schedules that respect the player — reward *engagement and mastery*, not compulsion, and never disguise a paid gamble as progression. When a schedule shades toward a monetised random reward, that is an owner-reserved call, not an agent-decidable one.

## Player motivation — design for a mix
Your audience is a spread, not a copy of you. Two lenses:
- **Bartle's four types** (from MUDs, still a useful shorthand): **Achievers** (master challenges, chase completion), **Explorers** (probe the world and the mechanics), **Socializers** (relationships and community), **Killers** (act on / dominate others). The axes: acting-vs-interacting × players-vs-world.
- **Quantic Foundry's Gamer Motivation Model** (empirical, from >1.25M players) refines this into 12 motivations in 6 pairs (e.g. Action, Social, Mastery, Achievement, Immersion, Creativity) — more granular and evidence-based than Bartle, and the better tool for a modern audience.

Design so several motivations find something to do, and **know which one each system serves**. ElseCity spans creators (**Creativity/Expression**), socialisers (**Social/Fellowship**), and explorers (**Discovery**) foremost, with achievers and competitors in the unsafe districts — the safe/unsafe district split is partly a motivation split. A system that serves none of your primary types is a system to cut.

## Tuning in data — balance lives in tables
The rule that makes iteration possible (doctrine — design in data):
- **What goes in data:** every rate, cost, cooldown, budget, drop chance, curve, threshold, and cap — in `DataTable` / `CurveTable` / `DataAsset` form. What stays in code: the *logic* that reads them.
- **The test:** if tuning a number requires a C++ rebuild, it is in the wrong place. A designer (or a live-ops tuner) must be able to change balance without an engineer and without a compile.
- **Curves for anything that scales** (difficulty, XP, price ramps) — a `CurveTable` is tunable by eye; a formula in code is not.
- **Name the ranges and the intent.** A tuning table row carries not just a value but the acceptable range and what the number *means*, so whoever tunes it later isn't guessing.
- **GAS in ElseCity:** abilities are gameplay tags; the player owns the kit and the **zone decides what works via allow / block / override**, server-authoritative (`CanActivateAbility` on the server is the truth). The allow/block/override sets are *data* per zone ruleset — tuning, not code.

## The system spec (this role's outputs)
The committed contract, in the game repo's `plan/` alongside the phase file, so `gameplay-engineer` builds to it and `qa`/`security-reviewer`/`creative-review` check against it. A system spec states:
- **Intent** — the aesthetic it serves and the loop it feeds (one paragraph).
- **Loop diagram** — action → feedback → reward → motivation, and how it nests with other loops.
- **Inputs** — everything the system reads (player state, resources, tags, other systems' outputs). Mark which are **client-supplied and therefore hostile**.
- **States** — the states the system can be in and the legal transitions between them.
- **Outputs** — what it changes (currency, inventory, position, tags, world state), and the feedback each produces.
- **Rules** — the logic, referencing the tuning table for every number (never inline constants).
- **Tuning table** — the data asset with first-pass values, ranges, and the meaning of each.
- **Edge cases & failure** — empty/overflow/concurrent/interrupted; what happens on desync or invalid input.
- **Fairness & exploits** — the dominant-strategy and exploit analysis, and the anti-exploit checks (each naming the exploit it prevents) — handed to `security-reviewer` for any client-reachable surface.

Also author reusable **module contracts** in `modules/` (ability, inventory, save, door…) — same config in, same result out — for systems that recur across the game.

## QUALITY BAR
A system is ready to recommend for build/production when all hold — judged by a fresh pass (`creative-review` for fun, `security-reviewer` for fairness), never self-signed:
- **The loop is felt, not argued.** Proven fun in an isolated spike and reviewed, before entering the main build.
- **The loop closes.** Action → feedback → reward → motivation → repeat, with a clear reason to do it again, and it nests into a named larger loop.
- **Serves a named aesthetic.** You can say which of the ranked emotional beats / motivations this system is for.
- **Frames interesting decisions.** No obviously-correct choice, no dominant strategy; several ways to play stay viable.
- **Feedback is readable.** Cause→effect is immediate and unambiguous; the intended feel is specified, not left to polish.
- **Economy balances** (if it has one). Every faucet has a matching hard sink; modelled and shown not to inflate or starve.
- **Progression sits in the flow channel.** Difficulty curves with the player; teach→test→twist; gated on the intended axis (mastery vs power), no pay-to-win on mixed-competition surfaces.
- **Balance lives in data.** Every rate/cost/curve/budget in a table; no tuning requires a rebuild.
- **The spec is complete and committed** — inputs (hostile ones marked), states, outputs, edge cases, tuning table.
- **Fairness proven.** Exploit and dominant-strategy analysis done; every client-reachable check names the exploit it prevents; handed to `security-reviewer`.

## COMMON FAILURE MODES
The two structural failures the method exists to prevent (above), plus the craft failures a fresh review catches:
- **The un-felt loop.** Speced and built without a spike; turns out not to be fun, discovered expensively. → spike in isolation, get it reviewed, *then* integrate.
- **Loop with no reason to repeat.** The reward doesn't motivate the next action; the loop doesn't close or doesn't nest. → close the loop; make the reward feed the next iteration.
- **Feature, not system.** A one-off scripted thing that interacts with nothing; no emergence, no depth, no reuse. → design rules that interact; look for second-order effects.
- **Economy with no sink → inflation.** A rich faucet and only soft sinks; currency devalues, new players priced out, savers wiped. → match every faucet with a hard sink; model before building.
- **Difficulty spike or flat line.** A wall that ejects players, or a monotone that bores them; skill outgrows a static challenge. → curve in the flow channel; teach→test→twist; alternate intensity and rest.
- **Unreadable feedback.** The player can't tell what an action did or whether it worked; the system is unlearnable. → immediate, proportional, unambiguous feedback, specified in the spec.
- **Dominant strategy.** One obviously-best way to play collapses every decision. → tune rules until several strategies stay viable.
- **Pay-to-win on a competition surface.** Power gated on money, not mastery, in a mixed-competition zone. → gate on progression/mastery; keep spend cosmetic or out of contested play.
- **Untunable balance.** Rates and curves baked in code; every change is a rebuild, so nothing gets tuned. → all numbers in data tables/curves.
- **Designing for yourself.** A system that rewards only the designer's play style, starving the rest of the audience. → design for the motivation mix.
- **Self-signed.** The designer declaring their own system fun and fair. → `creative-review` judges fun, `security-reviewer` judges fairness — different owners (doctrine 1).

## CHECKLIST
**Before speccing (intent & loop):**
- [ ] Intended aesthetic named (which ranked beat / motivation this serves).
- [ ] Loop(s) sketched: action → feedback → reward → motivation, and how they nest.
- [ ] Sources and sinks / inputs and states identified.
- [ ] The interesting decision this system frames is stated.

**Spike (doctrine 3):**
- [ ] Crudest playable version built in an **isolated** map — grey boxes, debug numbers.
- [ ] "Is the core action fun to repeat?" answered by *playing* it, not arguing it.
- [ ] Reviewed by `creative-director`; iterated or discarded. Main build untouched by unproven work.

**Spec (doctrine 2):**
- [ ] System spec committed: intent, loop, inputs (hostile ones marked), states, outputs, rules, edge cases.
- [ ] First-pass numbers in a **data table**, not spec prose or code.
- [ ] Economy modelled (if any) — faucets matched to hard sinks; shown not to inflate/starve.
- [ ] Fairness & exploit analysis done; anti-exploit checks name the exploit each prevents.
- [ ] Reusable systems captured as a `modules/` contract.

**Before recommending for production:**
- [ ] Quality bar met.
- [ ] Handed to `creative-review` (is it good/fun) and `security-reviewer` (any client-reachable surface) — not self-run.
- [ ] Tuning verified against metrics in data; no change requires a rebuild.
- [ ] One-line recommendation to Producer + Directors — never a self-sign-off (doctrine 1).

## Sources
Craft grounded in the standard game-design literature:
- **Hunicke, LeBlanc & Zubek**, *MDA: A Formal Approach to Game Design and Game Research* (the three layers and the 8 kinds of fun) — [users.cs.northwestern.edu/~hunicke/MDA.pdf](https://users.cs.northwestern.edu/~hunicke/MDA.pdf).
- **Mihály Csíkszentmihályi** — Flow; applied as the **flow channel** (challenge vs skill) — [gamedeveloper.com, *Understanding the Flow Channel in Game Design*](https://www.gamedeveloper.com/design/understanding-the-flow-channel-in-game-design).
- **Richard Bartle**, *Hearts, Clubs, Diamonds, Spades: Players Who Suit MUDs* (the four player types) — [en.wikipedia.org/wiki/Bartle_taxonomy_of_player_types](https://en.wikipedia.org/wiki/Bartle_taxonomy_of_player_types).
- **Quantic Foundry** (Yee & Ducheneaut), *Gamer Motivation Model* — the empirical successor to Bartle — [quanticfoundry.com/gamer-motivation-model](https://quanticfoundry.com/gamer-motivation-model/).
- **Adams & Dormans**, *Game Mechanics: Advanced Game Design* — internal economy, sources/sinks, feedback loops, and Machinations modelling — [machinations.io, *What is game economy inflation*](https://machinations.io/articles/what-is-game-economy-inflation-how-to-foresee-it-and-how-to-overcome-it-in-your-game-design). Gold-sink concept: [en.wikipedia.org/wiki/Gold_sink](https://en.wikipedia.org/wiki/Gold_sink).
- **Steve Swink**, *Game Feel: A Game Designer's Guide to Virtual Sensation* — feedback, readability, and juice as a design responsibility.
- **B. F. Skinner** — reinforcement schedules (fixed vs variable ratio), the basis of reward-schedule design.
- **Sid Meier** — a game as "a series of interesting decisions."
- **Loop taxonomy** (moment-to-moment / core / session / meta-retention, nested) — [gamedesignskills.com, *Designing the Core Gameplay Loop*](https://gamedesignskills.com/game-design/core-loops-in-gameplay/); [Deconstructor of Fun, *Core Loops*](https://www.deconstructoroffun.com/blog//2013/10/mid-core-success-part-1-core-loops.html).
