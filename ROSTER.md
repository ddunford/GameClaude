# The Studio Roster

The team, as agents. Three leadership **spines** meet in one **Director** (owner-reserved); departments hang off them; **Verify & Judge** gates work out, independent of who built it. Solo, these are hats — but the hats never merge build with verify.

**Status:** ✅ authored · ✍️ stub (author when its stage arrives) · ⏳ later (post-MVP).

## Leadership — the three spines
| Agent | Spine | Owns | Status |
|---|---|---|---|
| `director` | all three (fused) | Final "good / sound / ship" — **owner-reserved** | ✅ |
| `creative-director` | creative | Vision, pillars, on-pitch veto, spike review | ✅ |
| `technical-director` | technical | Architecture, UE5 calls, the `decide` call | ✅ |
| `producer` | production | Plan, sequence, gates, "you are here", resume | ✅ |

## Design (DSN)
| Agent | Owns | Status |
|---|---|---|
| `game-designer` | Mechanics, systems, economy, tuning data | ✅ |
| `level-designer` | Plan · metrics · blockout, from canonical views | ✅ |
| `narrative-ux` | Story-in-play, flows, onboarding, UMG logic | ⏳ |

## Art (ART)
| Agent | Owns | Status |
|---|---|---|
| `art-director` | Style bible, visual consistency | ✅ |
| `tech-artist` | Ingest, collision, budgets, materials, PCG | ✅ |
| `environment-artist` | Set-dressing, world materials | ✅ |
| `lighting-artist` | Day/night registers, exposure | ✅ |
| `concept-vfx-ui` | Reference, Niagara, UMG visuals | ⏳ |

## Engineering (ENG)
| Agent | Owns | Status |
|---|---|---|
| `network-engineer` | Replication, authority, persistence | ✅ |
| `gameplay-engineer` | Abilities, movement, feel (GAS, BP↔C++) | ✅ |
| `tools-programmer` | The `UnrealEngineMCP` toolkit — full editor access | ✅ |
| `engine-graphics-ai-build` | Perf, rendering, NPC, cook/package | ⏳ |

## Audio (AUD)
| Agent | Owns | Status |
|---|---|---|
| `sound-designer` | SFX, ambience, music, client-side wiring | ✅ |

## Verify & Judge (V&J) — builder-independent
| Agent | Owns | Status |
|---|---|---|
| `qa-visual` | Multi-view level QA battery | ✅ |
| `qa-network` | Server + 2 clients, negative tests | ✅ |
| `creative-review` | "Is it good?" — fresh judge, never the builder | ✅ |
| `security-reviewer` | Name the exploit each check prevents | ✅ |
| `engine-verifier` | Claims vs engine source | ✅ |

## Knowledge & Ops
| Agent | Owns | Status |
|---|---|---|
| `knowledge-keeper` | Design docs / source of truth, written-as-current | ✅ |

---
**20 agents authored** — the full core studio. Only post-MVP specialists (`narrative-ux`, `concept-vfx-ui`, `engine-graphics-ai-build`) remain as ⏳ stubs, authored when their stage arrives.

**Method depth** lives in `guides/` (authored so far: `tooling-ue`, `level-design`) and in `skills/` (to port from the game repo's `_archive/skills/` — read to port the *method*, not to copy). **Next scaffold work:** `hooks/` (guards + context injection + progress) and the remaining guides.
