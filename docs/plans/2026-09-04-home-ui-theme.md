# Home UI & Theme (phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Subagents must use `model: inherit`.

**Goal:** Restyle Stillvial Home with a shared Theme (primary/secondary/ghost buttons), soft gradient + decorative vial, and a single strong CTA — without changing gameplay or save logic.

**Architecture:** Extend `Palette` with UI surface tokens; build a `Theme` in GDScript (`ThemeFactory`) so StyleBoxes stay code-reviewable; apply it on Home; add a non-interactive `HomeBackdrop` Control that draws gradient + vial silhouette. `home.gd` only assigns button variants and keeps existing navigation/`SaveService` behavior.

**Tech Stack:** Godot 4.7 GDScript, embedded OFL fonts, `StyleBoxFlat`, `Control._draw()`, existing `Palette` / `home.tscn`.

## Global Constraints

- Spec: `docs/design/2026-09-04-home-ui-theme-design.md`
- English UI strings; docs in English
- Sensory-friendly: no neon; respect Low effects (skip entrance tweens when on)
- Modest devices: no heavy post-process; prefer `_draw()` / StyleBoxFlat
- Agent never runs `git commit` / `git push` — only suggest one-line `git commit -m "..."` commands
- Do not add throwaway test scripts; verify with Godot editor/Xvfb screenshots when useful
- Exactly one **primary** CTA on Home at a time

## File map

| Path | Role |
|------|------|
| `game/theme/fonts/` | OFL font files (display + UI) |
| `game/theme/theme_factory.gd` | Builds `Theme` with button/check/label styles |
| `game/theme/palette.gd` | Extend with UI colors / helpers |
| `game/ui/home_backdrop.gd` + node in home | Gradient + vial silhouette |
| `game/ui/home.tscn` | Layout hierarchy, theme application |
| `game/ui/home.gd` | CTA variant assignment; existing logic |
| `game/project.godot` | Optional `gui/theme/custom` if Theme saved as `.tres`; else apply in code |

---

### Task 1: Fonts + Palette UI tokens

**Files:**
- Create: `game/theme/fonts/` (two `.ttf` or `.otf`, OFL)
- Modify: `game/theme/palette.gd`
- Create: `game/theme/fonts/LICENSE.txt` (short attribution)

**Interfaces:**
- Produces: `Palette.SURFACE`, `Palette.SURFACE_RAISED`, `Palette.PRIMARY_FILL`, `Palette.PRIMARY_TEXT`, `Palette.OUTLINE`, `Palette.GHOST_TEXT` (Color constants)
- Produces: font files at `res://theme/fonts/display.ttf` and `res://theme/fonts/ui.ttf` (or `.otf` — keep these exact resource names via rename)

- [ ] **Step 1: Pick and vendor OFL fonts**

Download and place (rename on disk):

- Display: **Fraunces** (soft serif) → `game/theme/fonts/display.ttf`
- UI: **Source Sans 3** → `game/theme/fonts/ui.ttf`

Write `game/theme/fonts/LICENSE.txt` noting both are SIL OFL with upstream project names.

If download fails, fall back to **Literata** + **Nunito Sans** (also OFL) with the same filenames.

- [ ] **Step 2: Extend Palette**

Append to `game/theme/palette.gd` (keep existing water/pattern APIs unchanged):

```gdscript
## UI surfaces (Home / future HUD)
const SURFACE: Color = Color("0F2A32")
const SURFACE_RAISED: Color = Color("1A3A44")
const PRIMARY_FILL: Color = TEAL
const PRIMARY_TEXT: Color = Color("0A1A1E")
const OUTLINE: Color = Color(MIST.r, MIST.g, MIST.b, 0.55)
const GHOST_TEXT: Color = Color(MIST.r, MIST.g, MIST.b, 0.85)
const MUTED_TEXT: Color = Color(MIST.r, MIST.g, MIST.b, 0.7)
const DISABLED_FILL: Color = Color(TEAL.r, TEAL.g, TEAL.b, 0.35)
```

- [ ] **Step 3: Verify fonts import**

Run:

```bash
cd ~/work/opensource/stillvial/game
godot --headless --path . --quit-after 1
```

Expected: exits without missing-resource errors for the new fonts (Godot may write `.import` files).

- [ ] **Step 4: Suggest commit (human)**

```bash
cd ~/work/opensource/stillvial
git add game/theme/fonts game/theme/palette.gd
git commit -m "Add Home UI fonts and Palette surface tokens"
```

---

### Task 2: ThemeFactory (button / label / check styles)

**Files:**
- Create: `game/theme/theme_factory.gd`

**Interfaces:**
- Consumes: `Palette.*`, fonts at `res://theme/fonts/display.ttf`, `res://theme/fonts/ui.ttf`
- Produces: `ThemeFactory.build() -> Theme` with types:
  - `Button` default = secondary look
  - variations: `Primary`, `Secondary`, `Ghost` via `theme_type_variation` names `"Primary"`, `"Secondary"`, `"Ghost"`
  - `CheckButton`, `Label` (Default + `Title` / `Tagline` variations)

- [ ] **Step 1: Implement ThemeFactory**

Create `game/theme/theme_factory.gd`:

```gdscript
class_name ThemeFactory
extends RefCounted

const FONT_DISPLAY := preload("res://theme/fonts/display.ttf")
const FONT_UI := preload("res://theme/fonts/ui.ttf")

static func build() -> Theme:
	var t := Theme.new()
	_setup_fonts(t)
	_setup_buttons(t)
	_setup_check(t)
	_setup_labels(t)
	return t

static func _setup_fonts(t: Theme) -> void:
	t.set_default_font(FONT_UI)
	t.set_default_font_size(18)

static func _flat(bg: Color, border: Color, border_w: float, radius: float, expand_h: float = 10.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(int(border_w))
	s.set_corner_radius_all(int(radius))
	s.content_margin_left = 20.0
	s.content_margin_right = 20.0
	s.content_margin_top = expand_h
	s.content_margin_bottom = expand_h
	return s

static func _setup_buttons(t: Theme) -> void:
	var radius := 24.0
	# Secondary = default Button
	var sec_n := _flat(Color(0, 0, 0, 0), Palette.OUTLINE, 2.0, radius)
	var sec_h := _flat(Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.08), Palette.MIST, 2.0, radius)
	var sec_p := _flat(Color(Palette.TEAL.r, Palette.TEAL.g, Palette.TEAL.b, 0.2), Palette.TEAL, 2.0, radius)
	var sec_d := _flat(Color(0, 0, 0, 0), Color(Palette.OUTLINE.r, Palette.OUTLINE.g, Palette.OUTLINE.b, 0.3), 2.0, radius)
	for state in ["normal", "hover", "pressed", "disabled"]:
		pass
	t.set_stylebox("normal", "Button", sec_n)
	t.set_stylebox("hover", "Button", sec_h)
	t.set_stylebox("pressed", "Button", sec_p)
	t.set_stylebox("disabled", "Button", sec_d)
	t.set_stylebox("focus", "Button", sec_h)
	t.set_color("font_color", "Button", Palette.MIST)
	t.set_color("font_hover_color", "Button", Palette.MIST)
	t.set_color("font_pressed_color", "Button", Palette.MIST)
	t.set_color("font_disabled_color", "Button", Palette.MUTED_TEXT)
	t.set_font_size("font_size", "Button", 20)

	# Primary variation
	var pri_n := _flat(Palette.PRIMARY_FILL, Palette.PRIMARY_FILL, 0.0, radius)
	var pri_h := _flat(Palette.PRIMARY_FILL.lightened(0.08), Palette.PRIMARY_FILL, 0.0, radius)
	var pri_p := _flat(Palette.PRIMARY_FILL.darkened(0.08), Palette.PRIMARY_FILL, 0.0, radius)
	var pri_d := _flat(Palette.DISABLED_FILL, Palette.DISABLED_FILL, 0.0, radius)
	t.set_type_variation("Primary", "Button")
	t.set_stylebox("normal", "Primary", pri_n)
	t.set_stylebox("hover", "Primary", pri_h)
	t.set_stylebox("pressed", "Primary", pri_p)
	t.set_stylebox("disabled", "Primary", pri_d)
	t.set_stylebox("focus", "Primary", pri_h)
	t.set_color("font_color", "Primary", Palette.PRIMARY_TEXT)
	t.set_color("font_hover_color", "Primary", Palette.PRIMARY_TEXT)
	t.set_color("font_pressed_color", "Primary", Palette.PRIMARY_TEXT)
	t.set_color("font_disabled_color", "Primary", Color(Palette.PRIMARY_TEXT.r, Palette.PRIMARY_TEXT.g, Palette.PRIMARY_TEXT.b, 0.5))
	t.set_font_size("font_size", "Primary", 20)

	# Ghost variation
	var ghost := _flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0.0, radius, 8.0)
	t.set_type_variation("Ghost", "Button")
	for k in ["normal", "hover", "pressed", "disabled", "focus"]:
		t.set_stylebox(k, "Ghost", ghost if k != "hover" and k != "pressed" else _flat(Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.06), Color(0, 0, 0, 0), 0.0, radius, 8.0))
	t.set_color("font_color", "Ghost", Palette.GHOST_TEXT)
	t.set_color("font_hover_color", "Ghost", Palette.MIST)
	t.set_color("font_pressed_color", "Ghost", Palette.TEAL)
	t.set_color("font_disabled_color", "Ghost", Palette.MUTED_TEXT)
	t.set_font_size("font_size", "Ghost", 16)

	t.set_type_variation("Secondary", "Button")
	# Secondary variation mirrors default Button styles
	t.set_stylebox("normal", "Secondary", sec_n)
	t.set_stylebox("hover", "Secondary", sec_h)
	t.set_stylebox("pressed", "Secondary", sec_p)
	t.set_stylebox("disabled", "Secondary", sec_d)
	t.set_stylebox("focus", "Secondary", sec_h)
	t.set_color("font_color", "Secondary", Palette.MIST)
	t.set_color("font_hover_color", "Secondary", Palette.MIST)
	t.set_color("font_pressed_color", "Secondary", Palette.MIST)
	t.set_color("font_disabled_color", "Secondary", Palette.MUTED_TEXT)
	t.set_font_size("font_size", "Secondary", 20)

static func _setup_check(t: Theme) -> void:
	t.set_color("font_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_font_size("font_size", "CheckButton", 16)

static func _setup_labels(t: Theme) -> void:
	t.set_type_variation("Title", "Label")
	t.set_font("font", "Title", FONT_DISPLAY)
	t.set_font_size("font_size", "Title", 52)
	t.set_color("font_color", "Title", Palette.MIST)
	t.set_type_variation("Tagline", "Label")
	t.set_font("font", "Tagline", FONT_UI)
	t.set_font_size("font_size", "Tagline", 16)
	t.set_color("font_color", "Tagline", Palette.MUTED_TEXT)
```

Fix the Ghost loop so hover/pressed each get their own StyleBox instance (do not reuse one box incorrectly). Prefer explicit assignments like Primary.

Register script class: ensure `class_name ThemeFactory` is picked up (Godot scans on load).

- [ ] **Step 2: Smoke-load factory**

Run:

```bash
cd ~/work/opensource/stillvial/game
godot --headless --path . -e --quit-after 2
```

Or a one-liner in editor: evaluate `ThemeFactory.build()` — Expected: no preload errors.

- [ ] **Step 3: Suggest commit (human)**

```bash
git add game/theme/theme_factory.gd
git commit -m "Add ThemeFactory for primary secondary ghost buttons"
```

---

### Task 3: HomeBackdrop (gradient + vial)

**Files:**
- Create: `game/ui/home_backdrop.gd`
- Modify: `game/ui/home.tscn` (add Backdrop node behind Center)

**Interfaces:**
- Consumes: `Palette.DEEP`, `Palette.TEAL`, `Palette.MIST`
- Produces: `HomeBackdrop` Control, full-rect, `mouse_filter = MOUSE_FILTER_IGNORE`, draws gradient + vial

- [ ] **Step 1: Implement backdrop**

`game/ui/home_backdrop.gd`:

```gdscript
extends Control
## Soft deep→teal gradient and a large decorative vial silhouette.

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	# Vertical gradient via stacked rects (cheap, no shader required)
	var steps := 24
	for i in steps:
		var t := float(i) / float(steps - 1)
		var c := Palette.DEEP.lerp(Color(Palette.TEAL.r * 0.25, Palette.TEAL.g * 0.35, Palette.TEAL.b * 0.38), t * 0.85)
		var y0 := r.size.y * float(i) / float(steps)
		var y1 := r.size.y * float(i + 1) / float(steps)
		draw_rect(Rect2(0.0, y0, r.size.x, y1 - y0 + 1.0), c)
	# Soft vignette (corners)
	var vig := Color(0, 0, 0, 0.22)
	draw_rect(Rect2(0, 0, r.size.x, r.size.y * 0.08), Color(0, 0, 0, 0.12))
	draw_rect(Rect2(0, r.size.y * 0.92, r.size.x, r.size.y * 0.08), Color(0, 0, 0, 0.18))
	_draw_vial(r.size)

func _draw_vial(sz: Vector2) -> void:
	var cx := sz.x * 0.5
	var top := sz.y * 0.12
	var body_h := sz.y * 0.42
	var neck_w := mini(36.0, sz.x * 0.06)
	var body_w := mini(120.0, sz.x * 0.22)
	var ink := Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.14)
	# Neck
	draw_rect(Rect2(cx - neck_w * 0.5, top, neck_w, body_h * 0.18), ink, false, 2.0)
	# Body (rounded approx: rect + bottom arc)
	var body_top := top + body_h * 0.16
	var body := Rect2(cx - body_w * 0.5, body_top, body_w, body_h * 0.72)
	draw_rect(body, ink, false, 2.5)
	draw_arc(Vector2(cx, body.position.y + body.size.y), body_w * 0.5, 0.0, PI, 24, ink, 2.5, true)
```

Note: `draw_rect(..., false, width)` stroke API — in Godot 4 use `draw_rect(rect, color, false, width)` only if available; otherwise draw polyline outline. Prefer:

```gdscript
draw_polyline(PackedVector2Array([...outline points...]), ink, 2.5, true)
```

for a simple bottle outline if stroke rect is awkward.

- [ ] **Step 2: Insert into home.tscn**

As first child under `Home` (replace solid `Background` ColorRect usage):

- Remove or hide old `Background` ColorRect (or keep and set `visible = false`)
- Add `Backdrop` node type Control, script `home_backdrop.gd`, full rect, before `Center`

- [ ] **Step 3: Visual check**

```bash
# With Xvfb if needed
DISPLAY=:99 godot --path ~/work/opensource/stillvial/game --resolution 720x1280 --windowed
```

Expected: gradient + faint vial; no input blocking.

- [ ] **Step 4: Suggest commit (human)**

```bash
git add game/ui/home_backdrop.gd game/ui/home.tscn
git commit -m "Add Home gradient backdrop with vial silhouette"
```

---

### Task 4: Apply Theme + CTA hierarchy on Home

**Files:**
- Modify: `game/ui/home.gd`
- Modify: `game/ui/home.tscn` (theme_type_variation on buttons; Title/Tagline variations; min sizes)

**Interfaces:**
- Consumes: `ThemeFactory.build()`, SaveService mid-game / campaign level (existing)
- Produces: `_apply_theme()`, `_apply_cta_hierarchy()` called from `_ready` / `_refresh_labels`

- [ ] **Step 1: Scene polish**

On `home.tscn`:

- Title: `theme_type_variation = "Title"`
- Tagline: `theme_type_variation = "Tagline"`
- Continue / Play / Daily / Export / Import: leave variations to script
- Primary/secondary buttons `custom_minimum_size = Vector2(300, 52)`
- Ghost buttons keep ~134×40
- Increase VBox separation slightly (24)

- [ ] **Step 2: home.gd theme + CTA**

At top of `_ready()`:

```gdscript
theme = ThemeFactory.build()
```

Add:

```gdscript
func _apply_cta_hierarchy() -> void:
	var mid: Variant = SaveService.load_any_mid_game()
	var continue_is_primary := mid != null or CampaignSession.campaign_level > 1
	# Spec: Continue primary when resume/progress applies; else Play campaign primary
	if continue_is_primary:
		_continue_btn.theme_type_variation = "Primary"
		_play_btn.theme_type_variation = "Secondary"
	else:
		_continue_btn.theme_type_variation = "Secondary"
		_play_btn.theme_type_variation = "Primary"
	_daily_btn.theme_type_variation = "Secondary"
	if SaveService.is_daily_completed(SaveService.utc_date_key()):
		_daily_btn.modulate = Color(1, 1, 1, 0.65)
	else:
		_daily_btn.modulate = Color(1, 1, 1, 1)
	_export_btn.theme_type_variation = "Ghost"
	_import_btn.theme_type_variation = "Ghost"
```

Call `_apply_cta_hierarchy()` at end of `_refresh_labels()`.

Remove redundant per-control color overrides that fight the Theme (title/tagline/streak can keep light mist overrides or rely on Theme — prefer Theme).

Do **not** change `_on_continue` / `_on_play_*` / export-import logic.

- [ ] **Step 3: Manual acceptance**

Launch Home; confirm:

- One teal primary CTA
- Daily outlined
- Export/Import text-like
- Patterns / Low effects still save
- Continue / Play / Daily / Export still navigate correctly

Capture screenshot to `docs/screenshots/d18-home-restyle.png` if convenient.

- [ ] **Step 4: Suggest commit (human)**

```bash
git add game/ui/home.gd game/ui/home.tscn
git commit -m "Apply Theme and single primary CTA on Home"
```

---

### Task 5: Spec checklist + short design note

**Files:**
- Modify: `docs/design/2026-09-04-home-ui-theme-design.md` (check acceptance boxes)
- Modify: `docs/design/stillvial-design.md` — one short subsection pointing to Home Theme phase 1 (optional, 5–10 lines)

- [ ] **Step 1: Tick acceptance checks** in the phase-1 design doc that are done

- [ ] **Step 2: Suggest commit (human)**

```bash
git add docs/design
git commit -m "Mark Home UI Theme phase 1 acceptance checks"
```

---

## Self-review (plan vs spec)

| Spec requirement | Task |
|------------------|------|
| Shared Theme + StyleBoxes | Task 2 |
| Fonts display + UI | Task 1 |
| Palette tokens | Task 1 |
| Gradient + vial silhouette | Task 3 |
| Single primary CTA hierarchy | Task 4 |
| Ghost Export/Import, settings quieter | Task 4 |
| Low effects / no heavy FX | Tasks 3–4 (no entrance tweens required) |
| Out of scope board/HUD | Not in plan |
| No agent commits | Suggest-only steps |

No TBD placeholders remaining.
