# Game UI Theme (phase 2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax. Subagents must use `model: inherit`. Agent never `git commit` — only suggest one-line commits.

**Goal:** Restyle the play screen (HUD, board gradient, glass vials, tip/selection, win modal) using phase-1 `ThemeFactory`, without changing gameplay or save behavior.

**Architecture:** Apply shared Theme on `GameScreen`; replace solid board `ColorRect` with a gradient backdrop (no hero vial); strengthen `TubeView` glass StyleBox + static specular; style win panel + Primary next / Ghost home; calm highlights.

**Tech Stack:** Godot 4.7 GDScript, existing `ThemeFactory` / `Palette`, `StyleBoxFlat`, `Control._draw()`.

## Global Constraints

- Spec: `docs/design/2026-09-04-game-ui-theme-design.md`
- HUD: **zero** Primary buttons (all Secondary or Ghost)
- Win modal: **only** next-level is Primary; Home Ghost/Secondary
- Board gradient like Home; **no** decorative hero vial on play field
- Patterns / liquid logic unchanged; Low effects = no fancy animation
- English UI; agent does not commit; no throwaway test scripts
- Domain tests must still pass: `godot --headless --path game --script res://tests/run_domain_tests.gd`

## File map

| Path | Role |
|------|------|
| `game/ui/game_screen.gd` / `.tscn` | Theme; win overlay + modal variants |
| `game/ui/game_hud.gd` / scene nodes | Secondary/Ghost on buttons; label colors via Theme |
| `game/board/board_backdrop.gd` (+ board_view.tscn) | Gradient only |
| `game/board/tube_view.gd` | Glass stroke/fill + static specular; highlight polish |
| `game/theme/palette.gd` | Optional glass helper tweaks |
| `docs/design/2026-09-04-game-ui-theme-design.md` | Tick acceptance |
| `docs/screenshots/d19-game-restyle.png` | Optional QA shot |

---

### Task 1: Board gradient backdrop

**Files:**
- Create: `game/board/board_backdrop.gd`
- Modify: `game/board/board_view.tscn`, `game/board/board_view.gd`

**Interfaces:**
- Produces: full-rect Control, `MOUSE_FILTER_IGNORE`, draws DEEP→teal gradient (reuse HomeBackdrop math without vial)
- Consumes: `Palette.DEEP`, `Palette.TEAL`

- [ ] **Step 1: Implement `BoardBackdrop`**

Copy gradient + light vignette from `home_backdrop.gd` but **omit** `_draw_vial`. Script path `res://board/board_backdrop.gd`.

- [ ] **Step 2: Wire into BoardView**

Replace `Background` ColorRect with `Backdrop` Control + script (or keep ColorRect hidden). Remove `_bg.color = Palette.board_bg()` from `board_view.gd` `_ready` if `_bg` gone.

- [ ] **Step 3: Verify**

```bash
cd ~/work/opensource/stillvial/game && godot --headless --path . --quit-after 2
```

- [ ] **Step 4: Suggest commit (human)**

```bash
git add game/board/board_backdrop.gd game/board/board_view.tscn game/board/board_view.gd
git commit -m "Add play-board gradient backdrop without hero vial"
```

---

### Task 2: Glass vials + calm highlights

**Files:**
- Modify: `game/board/tube_view.gd`
- Optionally: `game/theme/palette.gd` (`glass_fill` / `glass_stroke` alphas)

**Interfaces:**
- Produces: richer StyleBoxFlat glass; static specular (ColorRect or draw on glass); tip/selection alpha tweak

- [ ] **Step 1: Strengthen `_style_glass`**

Example targets (tune to taste, keep modest):

```gdscript
sb.bg_color = Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.28)
sb.border_color = Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.7)
sb.set_border_width_all(2)
# keep rounded bottom
```

Add a thin static highlight child or draw a vertical mist line on the left of the glass (ignore mouse). Skip animation when `low_effects` is unknown at TubeView — keep specular always static (spec allows static under Low effects).

- [ ] **Step 2: Highlight polish in `_sync_highlight`**

Keep `Palette.selection()` / `tip_highlight()`; use modulate.a around 0.28–0.38; ensure highlight sits behind liquid / matches tube radius if easy (ColorRect OK).

- [ ] **Step 3: Verify domain tests still OK**

```bash
godot --headless --path ~/work/opensource/stillvial/game --script res://tests/run_domain_tests.gd
```

Expected: `DOMAIN_TESTS_OK`

- [ ] **Step 4: Suggest commit (human)**

```bash
git add game/board/tube_view.gd game/theme/palette.gd
git commit -m "Polish vial glass stroke and selection highlights"
```

---

### Task 3: GameScreen Theme + HUD button variants

**Files:**
- Modify: `game/ui/game_screen.gd`, `game/ui/game_hud.gd`, `game/ui/game_screen.tscn` (minsizes if needed)

**Interfaces:**
- Consumes: `ThemeFactory.build()`
- Produces: HUD buttons `theme_type_variation` Secondary or Ghost; **no** Primary on HUD

- [ ] **Step 1: Apply theme on GameScreen**

In `game_screen.gd` `_ready` first lines:

```gdscript
theme = ThemeFactory.build()
```

- [ ] **Step 2: HUD variants**

In `game_hud.gd` `_ready` after `@onready` resolve:

```gdscript
_undo_btn.theme_type_variation = "Ghost"
_reset_btn.theme_type_variation = "Secondary"
_tip_btn.theme_type_variation = "Ghost"
_home_btn.theme_type_variation = "Ghost"
```

(Or all Ghost / all Secondary — spec allows either; prefer Ghost for Undo/Tip/Home and Secondary for Reset, or all Ghost. **Never Primary.**)

Prefer Theme colors; keep light mist overrides on labels only if needed.

- [ ] **Step 3: Manual / visual check**

Launch a level; confirm HUD has no teal Primary fill.

- [ ] **Step 4: Suggest commit (human)**

```bash
git add game/ui/game_screen.gd game/ui/game_hud.gd game/ui/game_screen.tscn
git commit -m "Apply Theme to game HUD without primary CTAs"
```

---

### Task 4: Win modal polish

**Files:**
- Modify: `game/ui/game_screen.gd`, `game/ui/game_screen.tscn`

**Interfaces:**
- Dim ColorRect behind panel (`mouse_filter` STOP so board not clicked)
- Panel StyleBoxFlat `SURFACE_RAISED`
- WinLabel Title variation or display font size ~32–36
- NextButton Primary; HomeButton Ghost
- Behavior of `_on_next_level` / `_go_home` unchanged

- [ ] **Step 1: Scene structure**

Under `WinLayer/Center` (or full-rect sibling):

- `Dim` ColorRect full rect, color `Color(0,0,0,0.45)`, behind Panel
- Style Panel via script in `_ready`:

```gdscript
var sb := StyleBoxFlat.new()
sb.bg_color = Palette.SURFACE_RAISED
sb.set_corner_radius_all(20)
sb.content_margin_left = 24
sb.content_margin_right = 24
sb.content_margin_top = 20
sb.content_margin_bottom = 20
_win_panel.add_theme_stylebox_override("panel", sb)
_win_next.theme_type_variation = "Primary"
_win_home.theme_type_variation = "Ghost"
_win_label.theme_type_variation = "Title"
# optionally reduce title size for modal
_win_label.add_theme_font_size_override("font_size", 36)
```

- [ ] **Step 2: Ensure theme already applied** (Task 3) so variations work

- [ ] **Step 3: Visual win path** — complete a trivial pour or force `_on_level_completed` in editor; screenshot optional `docs/screenshots/d19-game-restyle.png`

- [ ] **Step 4: Suggest commit (human)**

```bash
git add game/ui/game_screen.gd game/ui/game_screen.tscn docs/screenshots/d19-game-restyle.png
git commit -m "Style win modal with dim overlay and primary next"
```

---

### Task 5: Docs acceptance

**Files:**
- Modify: `docs/design/2026-09-04-game-ui-theme-design.md`
- Optionally: `docs/design/stillvial-design.md` one-line pointer to phase 2

- [ ] Tick acceptance checks that are done
- [ ] Suggest commit:

```bash
git add docs/design
git commit -m "Mark game UI Theme phase 2 acceptance checks"
```

---

## Self-review (plan vs spec)

| Spec item | Task |
|-----------|------|
| Theme on game; HUD no Primary | Task 3 |
| Board gradient, no hero vial | Task 1 |
| Glass vials + patterns unchanged | Task 2 |
| Tip/selection calm | Task 2 |
| Win modal Primary next only | Task 4 |
| Low effects / no particles | Tasks 2–4 |
| Behavior unchanged | All (no logic rewrites) |
| Docs | Task 5 |
