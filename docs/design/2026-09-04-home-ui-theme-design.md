# Stillvial — Home UI & Theme (phase 1)

**Date:** 2026-09-04  
**Status:** Phase 1 implemented (acceptance checked 2026-09-04)  
**Scope:** Initial screens and buttons (Home first); shared Theme for later HUD reuse

## Goal

Replace the default Godot flat UI on Home with a hybrid look: **zen brand atmosphere** + **clear app-like CTAs**, sensory-friendly and readable on modest mobiles (720×1280).

Success: Home is recognizable as Stillvial without chrome; **one** obvious primary action; Export/settings do not compete; `Low effects` does not break layout.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Personality | Hybrid (zen title/atmosphere + tactile app buttons) |
| Button hierarchy | Single strong CTA; rest secondary/ghost |
| Background | Soft deep→teal gradient + large decorative vial silhouette behind brand |
| Implementation | Shared Godot `Theme` + StyleBoxes (not per-scene one-offs or heavy custom button scenes) |

## Visual system

### Tokens (extend `Palette`)

Reuse existing brand colors: `DEEP`, `TEAL`, `GOLD`, `MIST`.

Add (names may vary in code):

- `surface` / `surface_raised` — panel fills if needed later; Home may not need cards
- Button states: normal / hover / pressed / disabled for primary, secondary, ghost
- No neon glows, purple gradients, or default “AI UI” cream/serif-terracotta stacks

### Typography

- **Display** for title `Stillvial` (soft display or restrained serif, OFL/libre, embedded)
- **UI sans** for buttons and labels (not Inter / Roboto / Arial / system-ui as primary)
- Tagline: mist at ~70% opacity, smaller size

### Button variants

| Variant | Use | Look |
|---------|-----|------|
| **Primary** | Exactly one of Continue or Play campaign | Teal (or mist-on-teal) fill, capsule radius, min height ≥48px |
| **Secondary** | The other of Continue/Play; Daily | Outline mist/teal, quiet fill |
| **Ghost** | Export, Import | Text + hit area, minimal chrome |
| **CheckButton** | Patterns, Low effects | Same theme; calm track; no loud pills |

### Motion

- Optional soft press/hover only
- When `Low effects` is on: skip entrance tweens; static layout is fine

## Home layout

Single composition (not a dashboard):

1. Gradient background + light vignette  
2. Large vial silhouette (non-interactive, `mouse_filter = IGNORE`) as brand anchor  
3. Title + tagline  
4. **Primary CTA:** Continue — Level N when resume/progress applies; otherwise Play campaign. The non-primary of those two uses **secondary**  
5. Daily as **secondary** (label “Daily — done” when completed; subdued style)  
6. Streak line only if `streak > 0`  
7. Export | Import as **ghost** row  
8. Settings toggles at bottom, smaller type  

No cards, chips, stat strips, or floating badges on the hero.

### CTA logic

- Never show two primary buttons at once  
- Existing `home.gd` navigation and save/settings behavior stay; only presentation and which StyleBox/variant each control uses change  

## Technical scope (phase 1)

**In**

- `game/theme/` — `stillvial_theme` (+ font assets under `game/theme/fonts/` or `game/assets/fonts/`)
- Extend `palette.gd` (or theme builder) with surface/button helpers as needed  
- `ui/home.tscn` / `home.gd` — structure, CTA variant assignment, apply theme  
- Background: layered `ColorRect` / light shader / `_draw()` vial or simple vector/PNG  
- Ensure Home (and preferably project default theme) uses the Theme  

**Out (phase 2+)**

- Board, HUD, “Order restored” modal polish  
- New gameplay features  
- Store listing / app icon redesign  

## Constraints

- Keep performance-friendly (gl_compatibility / modest devices): avoid heavy post-process  
- Docs in English; UI strings remain English for now  
- Agent does not commit; human versions when ready  

## Acceptance checks

- [x] Title reads as brand hero; tagline supports, does not overpower  
- [x] One primary CTA visible; Daily/backup quieter  
- [x] Decorative vial visible but does not steal taps  
- [x] Patterns / Low effects still persist via `SaveService`  
- [x] Looks intentional on 720×1280 portrait  
- [x] Theme file reusable later for game HUD buttons  

**Evidence:** `docs/screenshots/d18-home-restyle.png` (720×1280); `ThemeFactory.build()`, `HomeBackdrop`, CTA hierarchy in `ui/home.gd`.  

