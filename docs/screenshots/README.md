# Screenshots (QA)

Captured 2026-09-04 during local playtesting.

## Desktop (Godot 4.7.2 + Xvfb) — working

| File | What it shows |
|------|----------------|
| `d09-home-full.png` | Home: Continue L12, Daily done, Streak 1, Export/Import, Patterns + Low effects ON |
| `d10-board.png` / `d04-board.png` | Level 12 board, patterns on vials, Undo/Reset/Tip/Home |
| `d06-after-tip.png` | Tip consumed (3→2), tip highlights on suggested vials |
| `d17-poured.png` | Pour works: Moves 1, red vial completed, **Order restored** → Level 13 / Home |

## Android emulator (`tradersworld`) — limited

AVD upgraded for this session to **720×1280**, **~2 GB RAM** (was 320×640 / 96 MB).

Still **cannot render Stillvial** under headless SwiftShader:

- **GLES (`gl_compatibility`)**: `Fragment shader active uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)` — SwiftShader limit; real phones are typically ≥1024.
- **Vulkan (`mobile`)**: present / black frame on `-no-window` emulator.

APK builds and installs (`export/android/stillvial.apk`). Validate on a **physical device** or an emulator with **host GPU + windowed** display.

Project keeps `rendering_method.mobile=gl_compatibility` for modest Android hardware.
