# The Studio Roster

The team, as agents. Three leadership **spines** meet in one **Director** (owner-reserved); departments hang off them; **Verify & Judge** gates work out, independent of who built it. Solo, these are hats — but the hats never merge build with verify.

**Status:** ✅ authored · 🔁 porting from trial-1 discipline · ✍️ stub (author when its stage arrives) · ⏳ later (post-MVP).

## Leadership — the three spines
| Agent | Spine | Owns | Gates | Status |
|---|---|---|---|---|
| `director` | all three (fused) | Final "good / sound / ship" — **owner-reserved** | Greenlight; every phase gate | ✍️ |
| `creative-director` | creative | Vision, pillars, on-pitch veto | All creative direction | 🔁 |
| `technical-director` | technical | Architecture, UE5 calls, scope/reversibility decisions | Code/architecture merges; the `decide` call | 🔁 |
| `producer` | production | Plan, sequence, gates, "you are here"; session resume | The *order* of work; milestone gates | 🔁 |

## Design (DSN) — reports to Game Director
| Agent | Owns | Status |
|---|---|---|
| `game-designer` | Mechanics, systems, economy, tuning data | ✍️ **new — priority** |
| `level-designer` | Plan · metrics · blockout, defined from canonical views | ✍️ **new — priority** |
| `narrative-ux` | Story-in-play, flows, onboarding, UMG logic | ⏳ |

## Art (ART) — reports to Art Director
| Agent | Owns | Status |
|---|---|---|
| `art-director` | Style bible, visual consistency | ✍️ new |
| `tech-artist` | Ingest, collision, budgets, materials, PCG (the UE5-critical hat) | 🔁 |
| `environment-artist` | Set-dressing, world materials | 🔁 |
| `lighting-artist` | Day/night registers, exposure | 🔁 |
| `concept-vfx-ui` | Reference, Niagara, UMG visuals | ⏳ |

## Engineering (ENG) — reports to Technical Director
| Agent | Owns | Status |
|---|---|---|
| `network-engineer` | Replication, authority, persistence, security | 🔁 |
| `gameplay-engineer` | Abilities, movement, feel (GAS, BP↔C++) | 🔁 |
| `tools-programmer` | The `ue-mcp-toolkit` — full editor access, closing gaps | 🔁 **priority** |
| `engine-graphics-ai-build` | Perf, rendering, NPC, cook/package | ⏳ |

## Audio (AUD)
| Agent | Owns | Status |
|---|---|---|
| `sound-designer` | SFX, ambience, music (generated), client-side wiring | 🔁 |

## Verify & Judge (V&J) — builder-independent
| Agent | Owns | Status |
|---|---|---|
| `qa-visual` | Multi-view level QA battery | 🔁 |
| `qa-network` | Server + 2 clients, negative tests | 🔁 |
| `creative-review` | "Is it good?" — fresh judge, never the builder | 🔁 |
| `security-reviewer` | Name the exploit each check prevents | 🔁 |
| `engine-verifier` | Claims vs engine source | 🔁 |

## Knowledge & Ops
| Agent | Owns | Status |
|---|---|---|
| `knowledge-keeper` | The design docs / single source of truth, written-as-current | 🔁 |

---
**Build order:** `producer` + `director` + `level-designer` + `game-designer` + `tech-artist` + `tools-programmer` first (Stage 0–1 + the toolkit), then the Verify & Judge layer, then the rest as their stage arrives. ~9 of these are ports of proven trial-1 disciplines (in `_archive/skills/` of the game repo — read to port the method, not to copy).
