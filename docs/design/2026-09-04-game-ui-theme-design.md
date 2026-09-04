# Stillvial — Game UI Theme (phase 2)

**Date:** 2026-09-04  
**Status:** Approved for planning  
**Depends on:** Phase 1 Home Theme (`docs/design/2026-09-04-home-ui-theme-design.md`)

## Goal

Bring the in-game screen into the same hybrid visual system as Home: calm atmosphere, shared `ThemeFactory`, board as the focus, sensory-friendly glass vials, and a clear win modal — without changing gameplay, save, or a11y patterns.

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Scope | Full play visual: HUD + board atmosphere + vial glass + tip/selection + win modal |
| HUD buttons | All Secondary or Ghost — **no** Primary on the play HUD (board stays the focus) |
| Win modal | Minimal panel + optional ritual title; **Primary** only on next level; Home Ghost/Secondary |
| Board backdrop | Soft deep→teal gradient like Home; **no** large decorative vial behind the board |
| Implementation | Reuse `ThemeFactory` + polish existing `tube_view` / board / win panel (approach 1) |

## HUD

- Apply `ThemeFactory.build()` on `GameScreen` (or HUD root).
- Level / Moves: UI font, mist; no cards or stat chips.
- Undo, Reset, Tip, Home: Secondary or Ghost only; same visual weight.
- Tip remains show/hide and enable/disable as today; when visible, not louder than siblings.
- Disabled states use Theme disabled styles (no harsh default grey).
- Optional: very subtle `SURFACE` strip behind HUD only if labels clash with board; prefer no heavy chrome.

## Board atmosphere

- Gradient soft `DEEP` → muted teal (same language as HomeBackdrop, without the hero vial).
- Tip / selection highlights: keep teal / gold semantics; calmer alpha and cleaner edges; no glow bloom.
- Low effects: no animated specular; static glass OK.

## Vials (glass)

- Stronger mist stroke + slightly clearer glass fill (`Palette.glass_*` or small helpers).
- Optional static inner highlight/specular line in `_style_glass` / draw path.
- Liquid bands and patterns unchanged (a11y first-class).

## Win modal (“Order restored”)

- Light dim overlay behind panel.
- Panel: `SURFACE_RAISED`, generous corner radius, no heavy drop shadow.
- Title: display-sized or Title variation (smaller than Home hero if needed).
- Next level button: **Primary** (only Primary on this screen).
- Home button: Ghost or Secondary.
- No confetti / particles.

## Out of scope

- Rules, solver, tips logic, save/export/import
- New audio
- Home restyle (phase 1 done)
- Store assets / icon

## Acceptance checks

- [x] GameScreen uses shared Theme; HUD has zero Primary buttons
- [x] Board gradient matches brand; no hero vial behind play field
- [x] Vials read as glass; patterns still clear
- [x] Tip/selection highlights calm and readable
- [x] Win modal: one Primary (next), Home quieter; dim overlay
- [x] Low effects does not break layout or require fancy animation
- [x] Navigation / undo / tip / win flow unchanged in behavior
