# Landscape — Water Sort / color sort (2026-09)

## Summary

- Date: 2026-09-04
- Main finding: The genre is heavily saturated on Play — titles with 10M+ and 100M+ installs reuse the same keywords and a “relax / no time limit” pitch. Verifiable privacy space is much smaller: Water Sort on F-Droid already ships offline, ad-free, tracker-free play. Still scarce: pattern-based accessibility, a reproducible local daily, and an open web demo.

## Table

| Name | Channel (Play/F-Droid/Web/GitHub) | Ads / IAP | Offline / apparent privacy | Twist or differentiator | Rating / signals | URL |
|------|-----------------------------------|-----------|----------------------------|-------------------------|------------------|-----|
| Water Sort Puzzle | Play | Ad / IAP policy not declared on the listing consulted. | Listing claims offline play; cannot conclude zero tracking. | Hundreds of levels, “happy glass” look, one-tap pour. | 100M+ installs on Play. | [Google Play](https://play.google.com/store/apps/details?id=com.gma.water.sort.puzzle) |
| Water Sort Quest | Play | Helper items; listing does not clarify IAP vs ads. | Promises no time limit and “anytime, anywhere”; privacy not verifiable from the description. | Hidden tubes/layers, customization, competitive ranking, red-green color-blind mode. | 10M+ installs on Play. | [Google Play](https://play.google.com/store/apps/details?id=com.mobirix.wspuzzle) |
| Water Sort Puzzle: Color Sort | Play | Power-ups and customization; monetization model unspecified. | No time limit; not enough to classify as offline / no-tracking. | Special levels, tall tubes, themes, power-ups. | 10M+ installs on Play. | [Google Play](https://play.google.com/store/apps/details?id=water.sorting.games.liquid.color.sort.puzzle&hl=es_US) |
| Water Hue - Water Sort Puzzle | Play | Listed as free; ads / IAP not specified. | Offline / no-tracking not declared; privacy policy linked. | ASMR sound, calm ritual tone, color bags, special rules. | Hundreds of levels and a “no timers” pitch. | [Google Play](https://play.google.com/store/apps/details?hl=en_US&id=com.water.hue.sort.puzzle.color.match.sorting.games) |
| Get Color - Water Sort Puzzle | Play | Terms and policy linked; ads / IAP not specified. | Offline / zero tracking not verifiable; support, Facebook, Instagram links present. | Mixes color match with water sort; claims 500+ puzzles. | Catalog signal: “500+” puzzles. | [Google Play](https://play.google.com/store/apps/details?id=com.zm.watersort) |
| Water Sort | F-Droid | No ads; no IAP declared. | 100% offline, no internet permission, no analytics/trackers per listing; APK rebuilt and signed by F-Droid. | Infinite procedural levels, minimal UI, calm palette. | Version 1.0.14 published 2026-08-26; Android 7+. | [F-Droid](https://f-droid.org/packages/com.sidhant.watersort/) |
| test-tubes | GitHub / Web | N/A: open-source prototype; no ads/IAP marketed. | Telemetry not documented; no explicit offline promise. | Godot 3 prototype with flexible UI and JSON level importer. | 11 GitHub stars; MIT. | [GitHub](https://github.com/1shevelov/test-tubes) |
| Magic Sort Clone | GitHub | N/A: open-source prototype. | Telemetry / offline support not documented. | Game-feel focus: anticipation, pour paths, haptics, particles, tube animation. | Unity 6 repo; 0 stars at check time. | [GitHub](https://github.com/yunusburkut/Magic-Sort-Clone) |
| rust-water-sort | GitHub | N/A: MIT repo; no ads/IAP marketed. | Telemetry / mobile-web shipping not documented. | Puzzle logic in Rust; useful reference for permissive licensing. | MIT license visible. | [GitHub](https://github.com/aoyama-val/rust-water-sort) |
| water-sort (upstream reference) | GitHub | N/A: source; no IAP advertised. | Claims 100% offline, zero tracking, no ads, no network permission (README claims). | Flutter, infinite procedural generation, minimal design, privacy priority. | 72 stars, 0 open issues, 2 forks, GPL-3.0. | [GitHub](https://github.com/sidhant947/water-sort) |
| water-sort (fork reference) | GitHub | N/A: source. | Fork of upstream; no independent monetization/privacy/offline statement. | Local implementation reference derived from upstream. | 0 stars, 0 open issues, 0 forks; fork by `waldopanozo`. | [GitHub](https://github.com/waldopanozo/water-sort) |

## Opportunity gaps

- Persistent patterns/shapes in addition to color: only one major competitor showed a red-green mode, not full non-color semantics for every color.
- Daily challenge reproducible by UTC date with a local-only streak — no ranking, account, or network.
- Coherent privacy package: offline, no ads/tracking, MIT source, future F-Droid; the F-Droid reference covers much of this but uses GPL-3.0.
- Open HTML5 web demo linkable from a portfolio, same game as Android; Play listings do not offer that surface.
- Truly zen tone with honest optional goals, instead of mixing “relax” with power-ups, rankings, or progression pressure.

## Threats / saturation

- Do not compete on generic queries “Water Sort Puzzle”, “Color Sort”, or “Liquid Sort”: many near-identical listings already own 10M+/100M+ installs.
- Do not copy “thousands of levels”, power-ups, extra tubes, rankings, or skins as the only differentiator — repeated patterns that dilute a zen promise.
- “No timer” alone is not enough; it appears on several commercial listings and in Water Hue positioning.
- Privacy alone is not exclusive: Water Sort is already on F-Droid, offline, and ad/tracker-free.

## Naming implications

- Avoid primary brand names like `Water Sort`, `Water Sort Puzzle`, `Color Sort`, `Liquid Sort`, `Bottle Game`, `Tube Puzzle`, `Get Color`, and equivalent descriptive compounds — saturated on Play and GitHub.
- Prefer a short, pronounceable brand that suggests calm and order without relying on the keyword; angles: `zen`, `calm`, `pour`, `pattern`, `daily`; `tube` works better as a secondary descriptor.
- Reserve “water sort puzzle” for subtitle, metadata, and store description — not the brand. Check exact collisions on Play, F-Droid, GitHub, and domain before deciding.
