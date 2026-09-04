# Brand and icon — Stillvial

Date: 2026-09-04. Chosen name: **Stillvial** (`stillvial`).

## Brand foundation

**Stillvial** joins *still* (quiet) and *vial* (vessel): a short brand that suggests calm ordering without saturated genre keywords. The promise accompanies habit — not productivity or competition.

- EN: “A small ritual of order, every day.”
- ES: «Un pequeño ritual de orden, cada día.»

### Primary tone: zen and serene

Voice is precise, warm, and quiet. It invites a short pause and celebrates progress without urgency: “One move at a time”, “Today’s challenge is ready”, “Order restored”. Avoid aggressive imperatives, rush-inducing counters, grandiose copy, and casino/arcade language (“Epic!”, “combo”, “reward”, “beat everyone”).

#### UI implications

- Lead with tubes, their patterns, and one primary action per screen; use negative space and calm typographic hierarchy.
- Keep pour animations short, fluid, and reversible; haptics and sound optional and subtle.
- No timer, energy, chests, coins, punitive streaks, or rankings. The local daily is an invitation, not an obligation.
- Treat pattern as a first-class signal beside color — on liquids, legends, and selection states — so play does not depend on chromatic vision alone.
- Use color for meaning and orientation, not constant decoration. Avoid white backgrounds with dominant purple and cream+terracotta schemes (overused stock looks).

## Icon directions

All three start from a flat background, generous margins, and simple geometry. These are specs for the ship icon, not final art assets.

### 1. Vial at rest

**Concept.** A vertical short-neck vial holds three horizontal liquid bands. The middle band has one simple wide wave; the others are clean fills. A small empty gap above the liquid signals stillness and keeps the silhouette readable without drops or shine.

**Palette.**

- `#12303A` — deep petrol blue, background
- `#E8F0E8` — soft mist, outline and details
- `#3E9B8E` — mineral green, primary layer
- `#D4B14B` — solar ochre, accent layer
- `#537B9C` — slate blue, secondary layer

**At 48 × 48.** Centered vial ~22–24 px wide × 32–34 px tall; neck ≥ 8 px; 2 px outline. Three bands of 6–7 px; middle wave is one wide curve, no fine texture. Vial mass ~60% of height for launcher-grid readability.

**Android.** Keep the vial inside the 66 × 66 dp adaptive safe zone on the petrol background; do not clip at the mask edge. Background layer may shift with the system; the vial must not touch the mask. Monochrome: single ink for vial and three divisions; keep the middle split via negative space or a 2 px stroke — do not rely on color.

### 2. Flow pattern

**Concept.** Three parallel curves settle into a rounded vial-like U — layers finding order. Abstraction of pouring and pattern accessibility; not realistic water or lab glassware.

**Palette.**

- `#102A43` — marine indigo, background
- `#D9E8F0` — mist blue, light lines
- `#2FA7A0` — calm turquoise, main flow
- `#E3C35C` — lichen yellow, accent
- `#5C789B` — steel blue, depth
- `#233D4D` — gray-blue, structural shadow

**At 48 × 48.** Outer U ~28–30 px wide; curves 3 px thick with ≥ 3 px gaps. Priority read: stable U + three strata — no fourth curve, gradients, or micro-detail.

**Android.** U and curves in the adaptive safe zone; marine fill bleeds to the edge. Monochrome: three solid curves inside the U with enough negative separation for circular/squircle OEM masks.

### 3. Assembled drop

**Concept.** A rounded drop split into four stacked pieces with slightly offset edges, each with an elementary geometric pattern (dot, dash, wave, grid). Communicates sorting layers without a literal tube; patterns lead.

**Palette.**

- `#163B36` — dark forest green, background
- `#C8E6DD` — pale mint, drop contrast
- `#4AAE9B` — jade, primary layer
- `#E0B452` — soft mustard, accent
- `#52758A` — dark mist blue, secondary layer
- `#F0F5EA` — greenish white, detail

**At 48 × 48.** Drop ~28–30 px tall × 22–24 px wide, rounded tip, four bands ≥ 5 px. At this size only one pattern should be visible on the app icon (dash or wave); reserve all four patterns for extended brand marks.

**Android.** Center the drop in the safe zone; forest fill bleeds. Monochrome: drop silhouette with three horizontal negative cuts — no inner patterns at small sizes.

## Comparison and recommendation

| Direction | Strengths | Risk |
|-----------|-----------|------|
| Vial at rest | Most genre-recognizable, sober, readable; links directly to Stillvial. | Can drift toward “labware” if the neck/outline become too technical. |
| Flow pattern | Motion, calm, accessibility without color dependence. | More abstract — needs careful craft to read as a game icon. |
| Assembled drop | Differentiable and pattern-forward. | “Drop” semantics are common; patterns do not all scale to 48 × 48. |

### v1 recommendation: Vial at rest

Choose **Vial at rest**. It is the clearest link between name, pour gesture, and serene tone; silhouette stays clear at 48 × 48; patterns can still show in-product. To avoid chemistry-app or shiny-clone vibes: rounded vial, three matte layers, no reflections, bubbles, neon, or gradients.

Direction 2 may later serve as secondary graphics (dividers, daily states, animated mark); it must not compete with the primary icon in v1.

## Final-art validation criteria

- Recognizable at 48 × 48 and in grayscale, with no text and no label dependence.
- Enough contrast between background and form; layer separation visible in monochrome.
- In-game layers/patterns keep a persistent non-chromatic identifier.
- No urgency, monetization, competition, or lab-fantasy cues.
