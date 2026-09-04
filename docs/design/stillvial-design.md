# Design — Stillvial

**Date:** 2026-09-04  
**Status:** approved (Phase 0 complete)  
**Engine:** Godot 4  
**Repo path:** `~/work/opensource/stillvial`  
**GitHub:** https://github.com/waldopanozo/Stillvial  

**Language:** all persistent project documentation is written in **English**.

---

## 1. Vision and v1 scope

### What it is

Open-source Water Sort–style puzzle (tubes + color pouring), 100% offline, no ads or tracking. Targets **Android** (Play + F-Droid when ready) and **Web** (HTML5 demo for portfolio). **No iOS** in the near term.

### Primary audience (design priority)

Stillvial is built **first** for people who benefit from calm, predictable, low-distraction play — especially **ADHD** and **autistic** players (and anyone who wants sensory-friendly puzzles). General “casual puzzle” users are welcome, but when trade-offs appear (stimulation vs calm, novelty vs predictability, monetization pressure vs safety), **prefer the neurodivergent-friendly option**.

This is **not** a medical product and must never claim to diagnose, treat, or cure ADHD or autism. Store copy should say *sensory-friendly / calm / low-pressure / accessible*, not therapy claims.

### Product goals

- Serve **both** cases: portfolio (demo + code) and store distribution with a path to **sustainable revenue** that does **not** rely on ads or surveillance.
- Prioritize **smooth play on modest phones**.
- Differentiate from generic Water Sort clones via **neurodivergent-first UX** (not only cosmetics).

### Neurodivergent-first UX pillars (v1+)

| Pillar | Product implications |
|--------|----------------------|
| Low pressure | Zen default: no timer, no energy, no punishing streaks, calm win copy |
| Predictability | Deterministic campaign seeds; clear rules; undo/reset always available |
| Multi-channel cues | Color **and** persistent patterns/shapes (not color-only); readable selection states |
| Sensory control | Optional sound/haptics (off or soft by default); **Low effects**; no flashing/neon spam |
| Focus-friendly chrome | One primary action per screen; minimal HUD clutter; no feed-like distraction |
| Privacy as safety | Offline gameplay; no ads/trackers (ads are especially hostile for attention & trust) |

### v1 twist (light combo)

| Piece | Behavior |
|-------|----------|
| Zen by default | No timer or pressure; optional honest stars / “par” |
| Daily challenge | Seed = UTC date; shared daily puzzle; local streak (non-punitive) |
| Accessibility | Patterns/shapes + color; sensory toggles |

### Kept from the reference Water Sort (the good parts)

- Campaign with seed = level number (reproducible puzzles)
- Random mode by difficulty
- Undo, limited tips, reset, mid-game resume
- Local multi-profile
- Themes / skins (reasonable v1 scope; avoid overstimulating palettes as default)
- Privacy-first (no network during gameplay)

### Out of v1 (shipped MVP game slice)

- iOS
- Cloud sync / accounts (see §8 for **v1.x optional identity** — not in current Godot MVP tasks 1–10)
- Ads, analytics, rewarded video
- Aggressive IAP / pay-to-win power-ups
- Long narrative
- Medical or therapeutic claims

### Revenue (aligned with privacy + audience)

Making money is an explicit project goal, but **without ads or tracking**. Preferred directions (pick later, document in store plan):

- Paid unlock / “Support Stillvial” one-time purchase, or tip jar
- Optional cosmetic packs that stay calm (no lootboxes)
- F-Droid build stays free/libre; Play may use paid unlock if needed

Never gate basic calm play behind surveillance or ad watching.

### Phase 0 (before game code) — complete

Market research → final name, brand tone, icon/palette brief, collision checks. See `docs/market-research/`.

---

## 2. Architecture (Godot 4)

```
stillvial/
├── docs/
│   ├── market-research/         # Phase 0
│   └── design/                  # product design
├── game/                        # Godot 4 project
│   ├── project.godot
│   ├── domain/                  # pure logic (no UI nodes)
│   │   ├── tube.gd
│   │   ├── level.gd
│   │   ├── pour_rules.gd        # single apply_pour
│   │   ├── level_generator.gd
│   │   └── level_solver.gd      # hints
│   ├── data/                    # local persistence
│   ├── board/                   # board scene + pour animation
│   ├── ui/                      # menus, HUD, settings
│   └── theme/                   # color + pattern by ID
├── export/                      # Android + Web presets
└── README.md
```

### Principles

1. **Domain first:** color identities as `int` / enum; theme maps ID → color + pattern.
2. **Single `apply_pour`:** used by generator, solver, and live play (avoid Flutter-fork duplication).
3. **Lean board:** `Tween` / simple shader; optional particles; **Low effects** setting for weak hardware.
4. **Local persistence first:** progress, profiles, mid-level state, daily — works with **zero network**. Optional cloud sync is additive (§8).
5. **One Godot project** exports Android (APK/AAB) and Web (HTML5).

### Performance (design requirements)

- Target ~60 fps on mid-range; degrade effects, not logic.
- Orthographic 2D only; no 3D physics.
- Explicit animation budget; avoid unnecessary per-frame UI work.

---

## 3. Game flow

### Player flow

1. **Home** — Continue / Campaign / Daily / Random / How to play / Settings  
2. **Campaign** — seed = N; documented difficulty curve (colors, capacity, scramble), tunable  
3. **Daily** — seed = UTC date; local completed-day streak  
4. **Match** — tap source → destination; pour; undo / tip / reset; resume on exit  
5. **Win** — zen feedback; **honest** move goal (solver solution length, or clearly labeled “estimated par” — never fake “optimal”)  
6. **Settings** — Zen (timer off by default), Low effects, patterns on/off, sound, profiles, theme  

### Tips

- Campaign levels 1–9: no tip button  
- Campaign ≥ 10, Random, and Daily: **3 tips** per puzzle  
- Failed tip (no solution): does not consume  
- Reset: restores to 3  
- Undo: does not restore tips  

### Phase 0 deliverables (done)

Folder: `docs/market-research/`.

| Deliverable | Content |
|-------------|---------|
| Landscape | 8–12 Water Sort clones (Play / F-Droid / web) |
| Naming | 10–15 candidates; GitHub / Play / domain checks; shortlist 3–5 |
| Brand | Zen tone; 2–3 icon directions + palette |
| Decision | Final name + icon brief |

---

## 4. Open source, portfolio, and success

### Repo and license

- Path: `~/work/opensource/stillvial/`  
- Remote: `waldopanozo/Stillvial`  
- **License: MIT**  
- README in **English**: pitch, privacy, build, screenshots, web demo link  
- Minimal `CONTRIBUTING.md`  
- Reasonable CI (Godot validation / export check); do not version local build or tool caches  

### Portfolio

- Entry on `waldopanozo.github.io`: one-line pitch, Godot 4 stack, badges (Android / Web / offline / no-tracking), links to GitHub + web demo  
- Do not wait for Play Store: web demo + repo cover the portfolio case  

### Privacy / stores

- No network during gameplay; no analytics/ads  
- Play / F-Droid when APK is stable and name/icon are locked  
- Store metadata in English (and ES if needed) at publish time  

### v1 success criteria

1. Smooth pour on a modest Android; **Low effects** available  
2. Campaign + Daily + Random playable offline  
3. Patterns in addition to color  
4. Web demo linked from the portfolio  
5. Domain separable from render and verifiable  

### Not v1 success

Play downloads, iOS, revenue.

---

## 5. Do not copy from the Flutter Water Sort

- Fake `optimalMoves` presented as optimal  
- Domain coupled to UI types (`Color` from Flutter)  
- Pour logic duplicated across generator / solver / VM / engine  
- Monolithic ~700–1100 LOC files  
- Unlimited tips / confusing toggle (use limited tip rules)  

---

## 6. Closed decisions

| Topic | Decision |
|-------|----------|
| Goal | Portfolio + stores (Android), modest-device performance, **neurodivergent-first** calm puzzle, privacy-preserving revenue |
| Mechanics | Water Sort + zen / daily / patterns / sensory controls |
| Stack | Godot 4 |
| v1 platforms | Android + Web; no iOS |
| License | MIT |
| Docs language | English |
| Folder | `opensource/stillvial`; portfolio only references it |
| Name | Stillvial / `stillvial` — approved 2026-09-04 |
| Icon | Vial at rest |
| Audience priority | ADHD / autistic / sensory-friendly players first; general casual second |
| Monetization | No ads/tracking; prefer one-time support/unlock or calm cosmetics |
| Identity / sync (v1.x) | **Guest-first**; local export/import; optional cloud on own servers; Google/Facebook login **optional only**, never required to play |

---

## 7. Next step

- Godot MVP plan (Tasks 1–10): `docs/plans/2026-09-04-stillvial-mvp-godot.md` — complete for local play.
- Follow-up plan: optional identity + sync + soft messaging (§8) after MVP is polished and export templates are installed.
- Home UI Theme phase 1 is done (§7.1); phase 2+ can reuse the Theme for board HUD.

### 7.1 Home UI Theme (phase 1)

Home now uses a shared Godot `Theme` (`ThemeFactory` + `Palette` tokens), a deep→teal gradient backdrop with a decorative vial silhouette, and a single primary CTA (Continue or Play). Export/Import are ghost; settings stay quiet. Spec, decisions, and acceptance: `docs/design/2026-09-04-home-ui-theme-design.md`. Screenshot: `docs/screenshots/d18-home-restyle.png`. Board/HUD restyle remains out of scope until a later phase.

---

## 8. Optional identity, sync, and belonging (v1.x)

**Decision (2026-09-04):** Option **D** — guest play is the priority; add **export/import** plus **optional** cloud sync on our servers; Google/Facebook may be offered as **optional** sign-in only.

### Truth about local progress

| Event | Typical outcome |
|-------|-----------------|
| App update (same package, data kept) | Progress usually kept |
| Clear storage / uninstall / new device | Local progress lost |
| Web/other browser profile | Separate local store |

So “belonging” across devices needs **explicit** backup or sync — never implied magic.

### Priority order (must not invert)

1. **Just play (guest)** — no account, no network, full campaign/daily/settings on device.  
2. **Export / import progress** (JSON file or share sheet) — offline belonging, open-source friendly, works even if the player rejects all accounts.  
3. **Optional cloud sync** on **our** backend — opt-in, calm copy, can revoke/delete.  
4. **Optional Google / Facebook login** — only as convenience providers for (3); never a hard gate; Play build may include them; F-Droid build should remain playable **without** proprietary SDKs (guest + export; sync via email/code if offered).

### What we may sync (opt-in)

- Campaign progress (level, max completed, stars if any)
- Settings (patterns, low effects, audio/haptics)
- Daily streak metadata (dates, not a public leaderboard by default)
- Soft product messages already delivered / dismissed (welcome, “cloud save on”, config tips)

### Soft messaging (calm, ADHD/autism-friendly)

- Welcome once for guests; separate short “Cloud backup is optional” when entering Account.
- Satisfaction / feedback: **opt-in**, infrequent, dismissible, never blocking play or tips.
- Config-change notes: one-line, quiet, not modal stacks.
- No red “streak broken” shame UX; no spam push unless explicitly enabled later.

### Backend (our servers)

- Open API + documented schema; prefer publishing server code under MIT alongside the client.
- Auth: session after optional OAuth or recovery; store minimal profile (provider id / opaque user id).
- Encryption in transit (HTTPS); delete-account endpoint; no ad/analytics SDKs.
- Client stays MIT; proprietary OAuth SDKs are **optional compile flavors**, not required for core.

### Open source & store fit

- Core loop remains free/libre and offline.  
- Optional proprietary login does **not** make the project closed-source, but F-Droid users should not be forced into it.  
- Store listing: emphasize offline + optional backup; never claim medical benefit; never require login to download/play.

### Non-goals for this feature

- Forced registration at first launch  
- Social feed, friends list, or competitive ranking as default  
- Selling personal data  
- Ads funded by “free account”
