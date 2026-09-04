# Stillvial MVP (Godot 4) Implementation Plan

> **For implementers:** Execute task-by-task. Steps use checkbox (`- [ ]`) syntax. After each task, the human versions with a one-line `git commit -m "..."` (agent never commits in this repo).

**Goal:** Ship a playable Stillvial vertical slice: Godot 4 project with pure domain (`apply_pour`), campaign levels (seed = N), board pour animation, zen-by-default session, local save/resume, then tips / daily / patterns / Android+Web export presets.

**Architecture:** `game/domain/` holds pure data + rules (no nodes). `game/board/` renders tubes and tweens pours. `game/ui/` is menus/HUD. `game/data/` persists with `ConfigFile`/`JSON`. One Godot project exports Android and Web later.

**Tech Stack:** Godot 4.x (stable), GDScript, MIT license, English docs.

## Global Constraints

- Project root: `/home/wpanozo/work/opensource/stillvial`
- Docs language: **English**
- Product: Water Sort + zen / daily / patterns; offline; no ads/tracking; MIT; Android + Web; no iOS
- Spec: `docs/design/stillvial-design.md`
- Brand: `docs/market-research/04-decision.md` (Stillvial, Vial at rest palette)
- applicationId: `com.waldopanozo.stillvial`
- Agent **never** runs `git commit` / `git push`; suggest one-line `git commit -m "..."` only (no HEREDOC)
- Do not mention AI/Cursor tooling in any file or commit message
- Prefer permanent domain tests under `game/tests/` (no throwaway scripts left behind)

---

## File map (MVP)

| Path | Responsibility |
|------|----------------|
| `game/project.godot` | Godot 4 project |
| `game/domain/water_color.gd` | Color id enum / constants |
| `game/domain/tube.gd` | Tube state + queries |
| `game/domain/pour_rules.gd` | Single `apply_pour` / `can_pour` |
| `game/domain/level.gd` | Level state, win check, move count |
| `game/domain/level_generator.gd` | Deterministic campaign generation |
| `game/domain/level_solver.gd` | DFS/BFS hints (later task) |
| `game/data/save_service.gd` | Local progress + mid-game |
| `game/board/board.tscn` + scripts | Tube layout + pour tween |
| `game/ui/home.tscn` | Continue / Campaign entry |
| `game/ui/game_hud.tscn` | Moves, undo, tip, reset |
| `game/theme/palette.gd` | id → Color + pattern |
| `game/tests/run_domain_tests.gd` | Headless domain assertions |
| `export/` | Android + Web presets (later) |
| `LICENSE` | MIT |
| `README.md` | Build/run instructions |

---

### Task 1: Install Godot 4 and scaffold project

**Files:**
- Create: `game/project.godot`
- Create: `game/icon.svg` (or use existing PNG as project icon reference)
- Create: `LICENSE`
- Modify: `README.md` (run instructions)
- Modify: `.gitignore` (ensure `.godot/` ignored)

**Interfaces:**
- Produces: openable Godot 4 project named Stillvial

- [ ] **Step 1: Install Godot 4.x stable**

On this machine Godot was not on PATH. Install one of:

```bash
# Option A: official tarball (example — use current stable 4.x from godotengine.org)
mkdir -p "$HOME/opt" && cd "$HOME/opt"
# download Godot 4 Linux x86_64 standard, unzip, symlink:
# ln -sf "$HOME/opt/Godot_v4.*_linux.x86_64" "$HOME/.local/bin/godot"
```

Verify:

```bash
godot --version
```

Expected: `4.x.x.stable` (or similar).

- [ ] **Step 2: Create project files**

`game/project.godot` minimal:

```ini
; Engine configuration file.
config_version=5

[application]
config/name="Stillvial"
config/description="A small ritual of order, every day."
run/main_scene="res://ui/home.tscn"
config/features=PackedStringArray("4.3", "Forward Plus")
config/icon="res://icon.svg"

[display]
window/size/viewport_width=720
window/size/viewport_height=1280
window/stretch/mode="canvas_items"
window/handheld/orientation=1

[rendering]
renderer/rendering_method="gl_compatibility"
```

Add a simple `game/icon.svg` (or copy palette-based placeholder). Create stub `game/ui/home.tscn` later in Task 5 if main_scene would break — for scaffold, temporarily set:

```ini
run/main_scene=""
```

until home exists, **or** create an empty `Node` scene `game/ui/boot.tscn` as main.

- [ ] **Step 3: LICENSE + README run section**

Add MIT `LICENSE` with copyright holder `Waldo M. Panozo` (or preferred legal name).

README append:

```markdown
## Development

- Engine: Godot 4.x
- Open `game/project.godot` in Godot, or:

```bash
cd game && godot --path . --editor
```
```

- [ ] **Step 4: Human versions**

```bash
git add LICENSE README.md .gitignore game/
git commit -m "Scaffold Godot 4 Stillvial project"
git push
```

---

### Task 2: Domain — tube + pour_rules (with tests)

**Files:**
- Create: `game/domain/water_color.gd`
- Create: `game/domain/tube.gd`
- Create: `game/domain/pour_rules.gd`
- Create: `game/tests/run_domain_tests.gd`

**Interfaces:**
- Produces:
  - `WaterColor` ids `0..N` (`EMPTY = -1` if needed)
  - `Tube.new(capacity: int, colors: Array[int])`
  - `PourRules.can_pour(from: Tube, to: Tube) -> bool`
  - `PourRules.apply_pour(from: Tube, to: Tube) -> int` # units moved; 0 if illegal
- Consumes: nothing

- [ ] **Step 1: Write failing tests first** (`run_domain_tests.gd`)

```gdscript
extends SceneTree

func _init() -> void:
	var failed := 0
	failed += _expect("empty cannot pour", not PourRules.can_pour(
		Tube.new(4, []), Tube.new(4, [])
	))
	var a := Tube.new(4, [1, 1])
	var b := Tube.new(4, [])
	failed += _expect("pour into empty", PourRules.can_pour(a, b))
	var moved := PourRules.apply_pour(a, b)
	failed += _expect("moved 2", moved == 2)
	failed += _expect("source empty", a.is_empty())
	failed += _expect("dest has two", b.colors == [1, 1])
	# same-color top only continuous block
	var c := Tube.new(4, [2, 1, 1])
	var d := Tube.new(4, [1])
	failed += _expect("pour matching top", PourRules.can_pour(c, d))
	moved = PourRules.apply_pour(c, d)
	failed += _expect("moved two ones", moved == 2 and d.colors == [1, 1, 1] and c.colors == [2])
	if failed == 0:
		print("DOMAIN_TESTS_OK")
		quit(0)
	else:
		print("DOMAIN_TESTS_FAILED ", failed)
		quit(1)

func _expect(label: String, cond: bool) -> int:
	if cond:
		return 0
	print("FAIL: ", label)
	return 1
```

- [ ] **Step 2: Run headless — expect FAIL** (classes missing)

```bash
cd /home/wpanozo/work/opensource/stillvial/game
godot --headless -s res://tests/run_domain_tests.gd
```

Expected: error / non-zero (not `DOMAIN_TESTS_OK`).

- [ ] **Step 3: Implement domain**

`tube.gd` (class_name Tube): colors index `0` = bottom, `last` = top; `capacity`; `is_empty`, `is_full`, `is_solved` (empty or single color full), `top_color`, `top_run_length`.

`pour_rules.gd` (class_name PourRules): static methods; move only continuous top run; dest empty or same top color; limited by free space.

- [ ] **Step 4: Run tests — expect PASS**

```bash
godot --headless -s res://tests/run_domain_tests.gd
```

Expected: prints `DOMAIN_TESTS_OK`, exit 0.

- [ ] **Step 5: Human versions**

```bash
git add game/domain game/tests
git commit -m "Add tube domain and single apply_pour with tests"
git push
```

---

### Task 3: Level model + campaign generator

**Files:**
- Create: `game/domain/level.gd`
- Create: `game/domain/level_generator.gd`
- Modify: `game/tests/run_domain_tests.gd` (add generator determinism + solvability smoke)

**Interfaces:**
- `LevelGenerator.generate(level_number: int) -> Level`
- Seed = `level_number` (deterministic)
- Color count formula (from design / reference): `(3 + (level - 1) / 3)` clamp 3–16
- Capacity: 6 if `level % 10 == 0` else 5 if `level % 5 == 0` else 4
- Empty tubes: 1 / 2 / 3 by color count bands (mirror reference research)
- Must only emit states where pour rules apply; validate solvable with limited DFS **or** generate by scrambling from solved (preferred for guaranteed solvability)

**Recommended generation approach (YAGNI-safe):** start from solved tubes, apply random legal reverse pours / shuffles with seeded RNG — always solvable.

- [ ] **Step 1: Add tests**

- Same `generate(7)` twice → identical tube color arrays  
- `generate(1)` has 3 colors, capacity 4  
- After generate, `level.is_complete()` is false  
- Optional: solver finds a solution within N states for levels 1–5  

- [ ] **Step 2: Implement `Level` + `LevelGenerator`**

- [ ] **Step 3: Headless tests pass**

- [ ] **Step 4: Human versions**

```bash
git add game/domain game/tests
git commit -m "Add deterministic campaign level generator"
git push
```

---

### Task 4: Board scene + pour animation

**Files:**
- Create: `game/theme/palette.gd` (ids → Color using Vial at rest palette + distinct extras)
- Create: `game/board/tube_view.gd` + `tube_view.tscn`
- Create: `game/board/board_view.gd` + `board_view.tscn`
- Create: `game/board/pour_animator.gd`

**Interfaces:**
- `BoardView.load_level(level: Level) -> void`
- `BoardView.tube_selected(index: int)` signal / selection logic
- On valid pour: play tween, then call `PourRules.apply_pour` once (domain remains source of truth)
- Setting hook `low_effects: bool` skips particles (particles optional; can be no-op in MVP)

**Palette (v1 base from brand):** `#12303A`, `#E8F0E8`, `#3E9B8E`, `#D4B14B`, `#537B9C` plus additional distinct water colors for higher levels.

- [ ] **Step 1: Implement tube views** (rect layers bottom→top; no particles required)

- [ ] **Step 2: Selection + pour**

Tap source (non-empty) → highlight; tap dest → if `can_pour`, tween top segment, then apply domain pour and refresh.

- [ ] **Step 3: Manual check in editor**

Load `generate(1)` on a test scene; complete a pour visually.

- [ ] **Step 4: Human versions**

```bash
git add game/board game/theme
git commit -m "Add board view with tweened pour animation"
git push
```

---

### Task 5: Game session UI (home + HUD + undo/reset)

**Files:**
- Create: `game/ui/home.tscn` + `home.gd`
- Create: `game/ui/game_screen.tscn` + `game_screen.gd`
- Create: `game/ui/game_hud.gd`
- Set `run/main_scene` to home

**Interfaces:**
- Home: Continue / Play campaign (current level)
- HUD: move count, Undo, Reset, (Tip placeholder disabled until Task 7)
- Session keeps `history: Array` of tube snapshots for undo
- Zen: no timer widget

- [ ] **Step 1: Wire navigation Home → GameScreen(level_number)**

- [ ] **Step 2: Undo / Reset**

Reset reloads generator for same N; undo restores previous snapshot.

- [ ] **Step 3: Win dialog** (calm copy: “Order restored”) — advance campaign index in memory for now

- [ ] **Step 4: Human versions**

```bash
git add game/ui game/project.godot
git commit -m "Add home and campaign game session with undo"
git push
```

---

### Task 6: Local save / resume

**Files:**
- Create: `game/data/save_service.gd`
- Modify: `game_screen.gd`, `home.gd`

**Interfaces:**
- `SaveService.save_progress(current_level: int, max_completed: int) -> void`
- `SaveService.save_mid_game(level_number: int, tubes, history, move_count) -> void`
- `SaveService.load_mid_game(level_number: int) -> Variant`
- Storage: `user://stillvial_save.cfg` via `ConfigFile` (no network)

- [ ] **Step 1: Persist after each successful pour + on win**

- [ ] **Step 2: Home Continue restores mid-game if present**

- [ ] **Step 3: Manual verify** — kill app mid-level, reopen, Continue works

- [ ] **Step 4: Human versions**

```bash
git add game/data game/ui
git commit -m "Persist campaign progress and mid-game resume"
git push
```

---

### Task 7: Limited tips + solver

**Files:**
- Create: `game/domain/level_solver.gd`
- Modify: HUD + game_screen

**Rules (from design):**
- Campaign 1–9: hide tip button
- Campaign ≥ 10 (and later Daily/Random): 3 tips; failed tip does not consume; reset refills; undo does not refill

- [ ] **Step 1: Solver returns next pour `(from, to)` or null**

- [ ] **Step 2: Tip button + remaining count**

- [ ] **Step 3: Highlight source/dest on board**

- [ ] **Step 4: Human versions**

```bash
git add game/domain game/ui game/board
git commit -m "Add limited tips powered by level solver"
git push
```

---

### Task 8: Patterns (accessibility) + Low effects toggle

**Files:**
- Modify: `palette.gd`, `tube_view.gd`, settings on home or simple pause menu

**Interfaces:**
- Each color id has `pattern: enum` (stripe, dots, wave, cross, …)
- Setting `patterns_enabled` (default on)
- Setting `low_effects` (default off)

- [ ] **Step 1: Draw pattern overlay on liquid bands**

- [ ] **Step 2: Settings toggles persist via SaveService**

- [ ] **Step 3: Human versions**

```bash
git add game/theme game/board game/ui game/data
git commit -m "Add color patterns and low-effects setting"
git push
```

---

### Task 9: Daily challenge

**Files:**
- Modify: home, generator (`generate_daily(date: String) -> Level` with seed from UTC `YYYYMMDD`)
- Save daily completion + streak locally

- [ ] **Step 1: Home Daily button**

- [ ] **Step 2: Seed from UTC date; 3 tips; no campaign progress coupling**

- [ ] **Step 3: Local streak increment on first clear of the day**

- [ ] **Step 4: Human versions**

```bash
git add game/
git commit -m "Add local UTC daily challenge with streak"
git push
```

---

### Task 10: Export presets (Android + Web) + README

**Files:**
- Create: `export/export_presets.cfg` (or Godot-managed under `game/`)
- Modify: `README.md` with export steps
- Note: applicationId `com.waldopanozo.stillvial`; use debug keystore locally

- [ ] **Step 1: Add Android + Web export presets in Godot**

- [ ] **Step 2: Document export commands / UI steps in README**

- [ ] **Step 3: Smoke-export Web build if templates installed; otherwise document template install**

- [ ] **Step 4: Human versions**

```bash
git add export game README.md
git commit -m "Add Android and Web export presets and docs"
git push
```

---

## Spec coverage

| Design requirement | Task |
|--------------------|------|
| Godot 4 scaffold | 1 |
| Domain + single `apply_pour` | 2 |
| Campaign seed = N | 3 |
| Board pour animation / Low effects hook | 4, 8 |
| Zen session, undo, reset | 5 |
| Local save/resume | 6 |
| Limited tips | 7 |
| Patterns | 8 |
| Daily | 9 |
| Android + Web exports | 10 |
| Portfolio link | Out of this plan (separate change in `waldopanozo.github.io`) |

## Execution

Plan saved at `docs/plans/2026-09-04-stillvial-mvp-godot.md`.

**Options:**

1. **Subagent-driven** — one task at a time with review  
2. **Inline** — execute in this session with checkpoints  

Which approach? (If you say “go”, start Task 1: install Godot + scaffold.)
