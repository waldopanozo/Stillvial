# Brand decision — Stillvial

**Date:** 2026-09-04  
**Status:** approved

## Identity

| Field | Value |
|-------|-------|
| Display name | Stillvial |
| Repo / folder | `stillvial` (kebab-case) |
| Tentative Android applicationId | `com.waldopanozo.stillvial` |
| License | MIT |
| Tagline (EN) | “A small ritual of order, every day.” |
| Tagline (ES) | «Un pequeño ritual de orden, cada día.» |

## Why this name

- Avoids saturated generic keywords such as `Water Sort Puzzle` and `Color Sort`; those stay in store metadata and descriptions only.
- Short and pronounceable in English and Spanish; joins *still* (calm) and *vial* (vessel), so it suggests quiet ordering without describing the genre generically.
- Initial checks found no exact game namesake; repeating `gh search repos Stillvial --limit 20` on 2026-09-04 returned zero repositories.
- Fits the zen promise and product differentiators: patterns beyond color, local daily challenge, offline play with no ads or tracking, and a neurodivergent-first calm UX (ADHD / autism / sensory-friendly priority — not medical claims).

## Icon brief (v1)

- Chosen direction: **Vial at rest**.
- Silhouette: rounded vertical short-neck vial with three horizontal liquid bands; the middle band has one wide wave; a small empty gap sits above the liquid.
- Palette: `#12303A`, `#E8F0E8`, `#3E9B8E`, `#D4B14B`, `#537B9C`.
- Do not include: text on the icon, more than two metaphors, shine, bubbles, neon, or gradients.
- Icon draft (2026-09-04): [`assets/stillvial-icon-vial-at-rest.png`](./assets/stillvial-icon-vial-at-rest.png) — validate contrast / Android adaptive mask before store use.

## Next step

Write the Godot MVP implementation plan and scaffold the game project.
