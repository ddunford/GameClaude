# Guide — Trust, safety & moderation craft (keeping the world safe to be in)

> Read before setting safety policy or reviewing any player-created or player-to-player surface. The core idea: **an all-ages, persistent, UGC-driven social city creates a harm surface the instant players can create and interact — and that surface, not any single feature, is the largest live risk the game carries. Safety is designed in before UGC ships, layered in depth, per-district, and server-authoritative. It is done when harmful content is prevented, detected, and actioned, when the age-gates are real, and when there is a path for the reported-on and the reviewer alike.**

`agents/security-reviewer` owns the *technical* exploit surface of an endpoint — what a hostile client can send and the check that stops it. **This guide owns the *human-harm and content* surface:** harassment, exploitation, illegal content, malicious or shocking UGC, and age-inappropriate material. The two **overlap on malicious UGC** — "data not code does not mean safe" — and neither owns it alone: a geometry payload is a technical DoS to security *and* a shock/harm vector here. Engine facts stay in `guides/unreal-engine.md`; the hard law (CSAM reporting duties, age-verification legal requirements, per-region regulation) belongs to a **legal/compliance** role — this guide owns policy and tooling and hands the hard law across.

## The two failures this prevents
1. **Policy retrofitted after the content is in.** Moderation is treated as a live-ops problem to solve after launch — so UGC ships with no reporting, no blocking, no age-gate, and no queue, and the first harm has no path to a response. The moderation surface exists the *instant* UGC ships; policy retrofitted after content is in is far costlier and there is no safe launch without the tooling (`guides/production-pipeline.md §3.5`).
2. **"Data not code" mistaken for "data is safe."** UGC is data, not user scripting — but geometry, textures, names, and audio are still an attack and harm surface. A whitelisted, budget-capped primitive set *limits* the surface; it does not make it safe. Malicious geometry, shock imagery, and grooming-via-chat are all reachable through "just data."

## PRINCIPLES
- **Safety is designed in, not moderated after.** The affordances — report, block, mute, hide, age-gate — and the policy behind them exist *before* players can create or interact. Retrofitting is the failure above.
- **Everything a player can create or send is a harm vector.** Geometry, textures/decals, world/avatar/item names, chat and text, audio, and any embedded link. Enumerate the surface the way security enumerates endpoints — completeness is the whole point.
- **Safety is per-district, not global.** Neon Hub is safe — trade, commerce, socialising, where new players start. The rest of the city is not, and consent is the act of walking there, so boundaries are **visually unmistakable**. Moderation policy layers on the district ruleset (`Zone.SafeHub`); "safe" and "mature" are properties of a place, applied by its ruleset, not one global setting.
- **All-ages by default; mature content behind a real, server-authoritative age-gate.** Reaching a mature zone is not eligibility — eligibility is **re-derived server-side** every transition and never taken on the client's claim (cross-ref `agents/security-reviewer`). *What* is gated is this role's policy; *how* age is verified is legal's.
- **Defense in depth.** Prevention (whitelist + budget caps + name filters) → detection (automated classification + player reports) → response (review + graduated enforcement) → appeal. No single layer is trusted to catch everything, because none does.
- **Proactive and reactive together.** Automated classification catches scale; human review catches nuance and context; player reporting catches what both miss. A moderation system with only one of the three has a blind spot the other two would cover.
- **Protect the moderators and the reported-on.** Reviewer welfare against graphic/illegal exposure is a duty, not a nicety; and the accused get due process — proportionate action and a real appeal. Safety is for everyone in the loop.
- **Log every action immutably.** Reports, evidence, decisions, and enforcement are an append-only, auditable trail (joins `guides/backend-services.md`'s ledger discipline). Compliance, appeals, and law-enforcement referral all depend on it.

## 1 — The UGC harm surface
Enumerate it completely; a surface you did not list is a surface you did not moderate. "Data not code does not mean safe."
- **Geometry.** Malicious meshes — shock/gore models, hate symbols built from primitives, sexual content, screamers, and **performance-DoS geometry** (absurd density crafted to crash or lag clients). The performance vector is shared with `agents/security-reviewer` and `agents/tech-artist` (budget caps limit it); the *content* vector — what the shape depicts — is this role's.
- **Textures & decals.** Any player-supplied or player-selected imagery — the richest vector for illegal, hateful, or age-inappropriate content, and the hardest to constrain by whitelist. Image classification and hash-matching (§4) live here.
- **Names & text.** World, avatar, and item names; chat; any free-text field. Slurs, harassment, grooming, doxxing, and evasion (leetspeak, unicode homoglyphs). Names are a broadcast surface — one offensive world name harms everyone who sees it.
- **Audio.** `agents/sound-designer`'s generated, ingested audio is safe by construction; **player-supplied or voice audio is not** — it carries the same harm classes as text plus voice-specific ones (voice harassment, audio shock). Gate and moderate any UGC/voice audio path.
- **Embedded links & references.** Any field that can carry a URL or an external reference is a vector to off-platform harm (phishing, illegal content, off-platform grooming). Default to no links; if allowed, filter and sandbox.
- **Composition & context.** Individually-clean primitives arranged into a harmful whole; a safe asset placed in a harmful context. Prevention by primitive-whitelist does not catch composition — detection and reporting must.

## 2 — Age & maturity gating
All-ages is the default posture; mature content is the exception, gated and server-authoritative.
- **All-ages by default.** Content, chat, and defaults assume a mixed-age audience unless a zone's ruleset says otherwise. The floor, not the ceiling, sets the default experience.
- **Mature zones behind a verified age-gate.** Zones flagged mature require verified age; the gate is **server-authoritative — re-derived on every transition**, never trusted from a client flag (`agents/security-reviewer`). A door into a mature zone is a gated transition like any paid or progression-gated one.
- **Policy here, verification with legal.** This role decides *what* is mature and *what* is gated; the *legal mechanism* of age verification (and the privacy/PII handling of it, which touches `guides/backend-services.md`'s PII isolation) is legal/compliance's. Flag the requirement; hand the hard law across.
- **Per-district, visually unmistakable.** A player must know, by looking, when they are crossing from safe to unsafe/mature — the boundary is a design obligation (`guides/level-design.md` treats the safe→unsafe edge as a Lynch edge, "visually unmistakable"). Consent is the walk; the walk must be informed.

## 3 — Reporting, flagging & blocking
The player-facing safety tools — the reactive layer players drive themselves.
- **Report, block, mute, hide.** Every player can report content/behaviour, block a player (no interaction either direction), mute (silence without blocking), and hide UGC. These are core UX, designed with `agents/ui-ux-designer` — reachable in two taps from any harm, not buried.
- **Triage & prioritisation.** Reports enter a queue prioritised by severity and signal (a CSAM report is not queued behind a spam report). Volume and repeat-target signals raise priority.
- **Reporting is itself a surface.** False-report brigading (mass-reporting a target to auto-action them) and report spam are abuse vectors — weight reports by reporter reputation, require corroboration for automated action, and never let raw report count alone trigger a ban.
- **Immediate protective actions.** Block and mute take effect instantly and client-side for the reporter's safety, independent of the review outcome — the victim is protected before the case is judged.

## 4 — Detection & classification
The proactive, scaled layer — automated where scale demands, human where nuance demands.
- **Automated classification.** Image, text, and audio classifiers flag likely-harmful content at ingest and in-world [verify — web pass: current content-moderation classification services and their categories]. Thresholds route: high-confidence-illegal to immediate action + referral, ambiguous to human review, clean to pass.
- **Hash-matching for known-bad.** Known CSAM and terrorist content are matched against industry hash lists (PhotoDNA/NCMEC-class, GIFCT-class) — a mandatory, non-discretionary layer for the worst content [verify — web pass: current hash-matching programs and access requirements]. This is where mandatory legal reporting duties attach (§6, legal).
- **Human-in-the-loop.** Classifiers catch scale but miss context, satire, and reclaimed language; humans catch what classifiers over- and under-flag. The two are a pipeline, not alternatives — automation triages, humans adjudicate the ambiguous.
- **Evasion is constant.** Homoglyphs, leetspeak, obfuscated imagery, and adversarial geometry evolve to beat filters; detection is maintained, not shipped-once. Log evasion patterns and feed them back.

## 5 — Response, enforcement & appeal
What happens after a violation is confirmed — proportionate, logged, appealable.
- **A graduated action ladder.** Warn → content removal → temporary restriction/suspension → ban → **law-enforcement referral** for illegal content. Action is proportionate to severity and history; a first minor offence and repeat CSAM are not the same lever.
- **Referral is mandatory, not discretionary, for the worst.** CSAM and credible threats are referred per legal duty (§6) — this is where the immutable evidence log (§Principles) is load-bearing.
- **Appeal is a right.** Every enforcement action the accused can appeal, reviewed by someone other than the original actor (the build≠verify separation, applied to enforcement — doctrine 1 in spirit). A moderation system with no appeal is an error the player cannot correct.
- **Evidence retention.** Actions retain the evidence and the decision immutably, for the appeal, for compliance, and for referral — with a retention policy legal sets (illegal content has special handling requirements).

## 6 — Moderator operations & welfare
The humans in the loop are part of the system, and they are exposed to its worst.
- **Queues with SLAs by severity.** CSAM and imminent-harm reports have a tight SLA; spam does not. The queue's ordering is a safety decision.
- **Reviewer welfare is a duty.** Exposure to graphic and illegal content harms reviewers; mitigate with content blurring/greyscale-by-default, exposure limits, rotation, and support. A system that burns out its moderators fails at scale.
- **Escalation paths.** A clear path from reviewer → senior → legal → law-enforcement for the content that requires it, with the immutable evidence trail attached.

## 7 — Governance & transparency
The policy layer the whole system executes.
- **Community guidelines.** A public, enforceable statement of what is and isn't allowed, per-district where the rules differ (safe Hub vs unsafe/mature districts). Enforcement without a published rule is arbitrary.
- **Transparency.** Report volumes, action rates, and appeal outcomes reported at a cadence — internal always, public where regulation or trust requires [verify — web pass: transparency-reporting obligations].
- **Per-region legal duties — flag and hand off.** All-ages + mature + UGC + social + payments pulls in child-safety and platform regulation (COPPA-class for minors, DSA-class platform duties, age-appropriate-design codes) that vary by region [verify — web pass: current regulatory obligations by region]. **This role names the obligation; legal/compliance owns compliance.**

## QUALITY BAR
A safety surface is ready to recommend when all of these hold — verified, never self-signed:
- **Complete surface.** Every UGC and player-to-player vector (geometry, texture, name, text, audio, link, composition) is enumerated and has a prevention/detection/response answer.
- **Designed-in tools.** Report, block, mute, and hide exist, are two taps from any harm, and block/mute protect the victim instantly and independently of the review outcome.
- **Real age-gates.** Mature-zone eligibility is re-derived server-side every transition, never client-claimed; boundaries are visually unmistakable.
- **Depth, not a single layer.** Prevention, detection (automated + reports), response, and appeal are all present; no single layer is the only thing standing between a player and harm.
- **Known-bad covered.** Hash-matching for CSAM/terror content is in place with a mandatory, non-discretionary referral path and evidence retention.
- **Proportionate & appealable.** A graduated action ladder; every action logged immutably and appealable to a different reviewer.
- **Moderators protected.** Severity-ordered queues with SLAs; reviewer welfare mitigations; clear escalation to legal/law-enforcement.
- **Governed.** Published, per-district community guidelines; the per-region legal surface named and handed to compliance.

## COMMON FAILURE MODES
- **Retrofitted policy.** UGC ships with no reporting/blocking/age-gate/queue; the first harm has no path. → policy in Phase 1, tooling in Phase 2, before UGC ships.
- **"Data is safe" fallacy.** Trusting the primitive-whitelist to make UGC harmless, so shock geometry / hateful textures / grooming chat sail through. → enumerate every vector; prevention limits, it never suffices.
- **Client-asserted age-gate.** A mature-zone gate the client can flag past. → re-derive eligibility server-side every transition (`security-reviewer`).
- **Single-layer moderation.** Only automated filters (miss context) or only reports (miss what no one reports) or only manual (doesn't scale). → all three, as a pipeline.
- **Report-count-as-truth.** Raw report volume auto-actions a target, so brigading weaponises the system. → weight by reporter reputation; require corroboration; humans adjudicate.
- **No appeal.** Enforcement the accused cannot contest, judged once by one person. → appeal to a different reviewer; evidence retained.
- **Reviewer burnout.** Unmitigated exposure to the worst content. → blur/greyscale defaults, exposure limits, rotation, support.
- **No immutable log.** Actions and evidence mutable or unretained, so appeal, compliance, and referral have nothing to stand on. → append-only, retained per legal policy.
- **Legal treated as owned here.** Guessing at CSAM-reporting or age-verification law instead of routing it. → name the obligation, hand the hard law to compliance/legal.

## CHECKLIST
**Policy (before UGC exists):**
- [ ] Community guidelines drafted, per-district where rules differ; the safe→unsafe/mature boundary is a design obligation on `level-designer`.
- [ ] Every UGC and player-to-player harm vector enumerated with a prevention/detection/response answer.
- [ ] Mature-content policy set; age-gate specified as server-authoritative; the verification mechanism's legal need flagged to compliance.
- [ ] Per-region regulatory surface (minors, platform duties) named and handed to legal.

**Tooling (before launch):**
- [ ] Report / block / mute / hide built, reachable in two taps, with block/mute protecting the victim instantly.
- [ ] Automated classification + known-bad hash-matching in place; thresholds route to action / human / pass.
- [ ] Human review queue with severity SLAs; reviewer welfare mitigations; escalation to legal/law-enforcement.
- [ ] Graduated enforcement ladder + appeal to a different reviewer; immutable evidence log with a retention policy.
- [ ] Reporting-abuse (brigading/spam) resistance built in.

**Before recommending done:**
- [ ] Quality bar met.
- [ ] Malicious-UGC surface reviewed jointly with `agents/security-reviewer` (technical DoS) and `agents/tech-artist` (budget caps).
- [ ] Age-gate verified server-authoritative via `agents/qa-network`'s negative test (reaching the zone ≠ eligibility).
- [ ] The legal/compliance surface handed off, not guessed.

## Sources
Craft grounded in the standard trust-&-safety literature; specifics to re-confirm on the web pass are tagged `[verify — web pass]`:
- **Trust & Safety Professional Association (TSPA)** and the **Digital Trust & Safety Partnership** — moderation operations, enforcement, and reviewer welfare `[verify — web pass]`.
- **Hash-matching programs** — PhotoDNA / NCMEC for CSAM, GIFCT for terrorist content: access requirements and mandatory-reporting duties `[verify — web pass]`.
- **Platform regulation** — COPPA (minors), the EU Digital Services Act (platform duties, transparency reporting), age-appropriate-design codes; obligations by region `[verify — web pass]`.
- **Content-classification services** — current automated image/text/audio moderation offerings and their category taxonomies `[verify — web pass]`.
- **UGC-platform safety models** — Roblox / Fortnite-Creative-class safety systems as reference points for an all-ages UGC world `[verify — web pass]`. Engine facts stay in `guides/unreal-engine.md`; the age-gate's server-authority is `agents/security-reviewer`'s to enforce.
