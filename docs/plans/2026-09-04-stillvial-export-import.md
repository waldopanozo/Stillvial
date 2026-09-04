# Stillvial — Local export / import progress

**Goal:** Guest players can back up and restore progress without any account (design §8 step 1).

**Architecture:** Snapshot JSON via `SaveService`; Home buttons Export / Import; optional mid-game included; calm feedback; no network.

**Tech:** Godot 4 GDScript, `JSON` + `FileAccess`, `FileDialog` when available.

## Constraints

- Guest-first; no login required
- English UI strings
- Agent does not commit
- Round-trip tested headless where possible

## Tasks

### Task 1: Snapshot API + tests
- `SaveService.build_export_dict()` / `apply_import_dict(data) -> bool`
- Format `stillvial-progress` version 1: progress, settings, daily, mid_game
- Headless round-trip test

### Task 2: File I/O + Home UI
- Write/read `user://stillvial_backup.json` + FileDialog on desktop
- Home: Export / Import buttons + calm status label
- After import, refresh Continue/streak/settings

### Task 3: Docs
- Short README note under Development / Backup
