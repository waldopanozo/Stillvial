class_name SaveService
extends RefCounted

## Local campaign progress + mid-game resume (ConfigFile, no network).
## Optional JSON export/import for guest backup (no account required).

const PATH := "user://stillvial_save.cfg"
const EXPORT_PATH := "user://stillvial_backup.json"
const EXPORT_FORMAT := "stillvial-progress"
const EXPORT_VERSION := 1
const SECTION_PROGRESS := "progress"
const SECTION_MID := "mid_game"
const SECTION_SETTINGS := "settings"
const SECTION_DAILY := "daily"

## Accessibility / sensory defaults: patterns ON, low effects OFF.
const DEFAULT_PATTERNS_ENABLED := true
const DEFAULT_LOW_EFFECTS := false

static func save_settings(patterns_enabled: bool, low_effects: bool) -> void:
	var cfg := _load_cfg()
	cfg.set_value(SECTION_SETTINGS, "patterns_enabled", patterns_enabled)
	cfg.set_value(SECTION_SETTINGS, "low_effects", low_effects)
	_write_cfg(cfg)

static func load_settings() -> Dictionary:
	var cfg := _load_cfg()
	return {
		"patterns_enabled": bool(cfg.get_value(
			SECTION_SETTINGS, "patterns_enabled", DEFAULT_PATTERNS_ENABLED
		)),
		"low_effects": bool(cfg.get_value(
			SECTION_SETTINGS, "low_effects", DEFAULT_LOW_EFFECTS
		)),
	}

static func save_progress(current_level: int, max_completed: int) -> void:
	var cfg := _load_cfg()
	cfg.set_value(SECTION_PROGRESS, "current_level", maxi(current_level, 1))
	cfg.set_value(SECTION_PROGRESS, "max_completed", maxi(max_completed, 0))
	_write_cfg(cfg)

static func load_progress() -> Dictionary:
	var cfg := _load_cfg()
	return {
		"current_level": int(cfg.get_value(SECTION_PROGRESS, "current_level", 1)),
		"max_completed": int(cfg.get_value(SECTION_PROGRESS, "max_completed", 0)),
	}

static func save_mid_game(level_number: int, tubes, history, move_count, capacity: int = -1) -> void:
	var cfg := _load_cfg()
	var cap: int = capacity if capacity >= 1 else _infer_capacity(history, tubes)
	cfg.set_value(SECTION_MID, "active", true)
	cfg.set_value(SECTION_MID, "level_number", level_number)
	cfg.set_value(SECTION_MID, "tubes", _deep_copy(tubes))
	cfg.set_value(SECTION_MID, "history", _deep_copy(history))
	cfg.set_value(SECTION_MID, "move_count", int(move_count))
	cfg.set_value(SECTION_MID, "capacity", cap)
	_write_cfg(cfg)

static func load_mid_game(level_number: int) -> Variant:
	var cfg := _load_cfg()
	if not bool(cfg.get_value(SECTION_MID, "active", false)):
		return null
	var saved_level: int = int(cfg.get_value(SECTION_MID, "level_number", -1))
	if saved_level != level_number:
		return null
	return {
		"level_number": saved_level,
		"tubes": _deep_copy(cfg.get_value(SECTION_MID, "tubes", [])),
		"history": _deep_copy(cfg.get_value(SECTION_MID, "history", [])),
		"move_count": int(cfg.get_value(SECTION_MID, "move_count", 0)),
		"capacity": int(cfg.get_value(SECTION_MID, "capacity", 4)),
	}

## Mid-game payload regardless of level, or null.
static func load_any_mid_game() -> Variant:
	var cfg := _load_cfg()
	if not bool(cfg.get_value(SECTION_MID, "active", false)):
		return null
	var saved_level: int = int(cfg.get_value(SECTION_MID, "level_number", -1))
	if saved_level < 1:
		return null
	return load_mid_game(saved_level)

static func clear_mid_game() -> void:
	var cfg := _load_cfg()
	if cfg.has_section(SECTION_MID):
		cfg.erase_section(SECTION_MID)
	_write_cfg(cfg)

static func has_mid_game() -> bool:
	return load_any_mid_game() != null

## UTC calendar day as `YYYYMMDD`.
static func utc_date_key(unix_time: int = -1) -> String:
	var t: int = unix_time if unix_time >= 0 else int(Time.get_unix_time_from_system())
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(t)
	return "%04d%02d%02d" % [int(d.year), int(d.month), int(d.day)]

static func load_daily() -> Dictionary:
	var cfg := _load_cfg()
	return {
		"last_completed_date": str(cfg.get_value(SECTION_DAILY, "last_completed_date", "")),
		"streak": maxi(int(cfg.get_value(SECTION_DAILY, "streak", 0)), 0),
	}

## First clear of `date_key` increments streak (consecutive UTC days).
## Re-clearing the same day is a no-op. Gaps reset count calmly to 1 (no penalty UX).
static func register_daily_clear(date_key: String) -> Dictionary:
	var key: String = date_key.strip_edges()
	var state: Dictionary = load_daily()
	var last: String = str(state.get("last_completed_date", ""))
	var streak: int = int(state.get("streak", 0))
	var first_clear: bool = last != key
	if first_clear:
		if last != "" and last == _previous_utc_date_key(key):
			streak += 1
		else:
			streak = 1
		var cfg := _load_cfg()
		cfg.set_value(SECTION_DAILY, "last_completed_date", key)
		cfg.set_value(SECTION_DAILY, "streak", streak)
		_write_cfg(cfg)
	return {
		"last_completed_date": key if first_clear else last,
		"streak": streak,
		"first_clear": first_clear,
	}

static func is_daily_completed(date_key: String) -> bool:
	var state: Dictionary = load_daily()
	return str(state.get("last_completed_date", "")) == date_key.strip_edges()

## Guest backup snapshot (no account). Includes mid-game when active.
static func build_export_dict() -> Dictionary:
	var mid: Variant = load_any_mid_game()
	return {
		"format": EXPORT_FORMAT,
		"version": EXPORT_VERSION,
		"exported_at": Time.get_datetime_string_from_system(true),
		"progress": load_progress(),
		"settings": load_settings(),
		"daily": load_daily(),
		"mid_game": mid if mid != null else {},
	}

## Apply a previously exported snapshot. Returns false if format is invalid.
static func apply_import_dict(data: Variant) -> bool:
	if not (data is Dictionary):
		return false
	var d: Dictionary = data
	if str(d.get("format", "")) != EXPORT_FORMAT:
		return false
	var ver: int = int(d.get("version", 0))
	if ver < 1 or ver > EXPORT_VERSION:
		return false
	var progress_raw: Variant = d.get("progress", {})
	var settings_raw: Variant = d.get("settings", {})
	var daily_raw: Variant = d.get("daily", {})
	if not (progress_raw is Dictionary and settings_raw is Dictionary and daily_raw is Dictionary):
		return false
	var progress: Dictionary = progress_raw
	var settings: Dictionary = settings_raw
	var daily: Dictionary = daily_raw
	save_progress(
		int(progress.get("current_level", 1)),
		int(progress.get("max_completed", 0))
	)
	save_settings(
		bool(settings.get("patterns_enabled", DEFAULT_PATTERNS_ENABLED)),
		bool(settings.get("low_effects", DEFAULT_LOW_EFFECTS))
	)
	var cfg := _load_cfg()
	cfg.set_value(
		SECTION_DAILY,
		"last_completed_date",
		str(daily.get("last_completed_date", ""))
	)
	cfg.set_value(SECTION_DAILY, "streak", maxi(int(daily.get("streak", 0)), 0))
	_write_cfg(cfg)
	var mid_raw: Variant = d.get("mid_game", {})
	if mid_raw is Dictionary and not mid_raw.is_empty() and int(mid_raw.get("level_number", 0)) >= 1:
		save_mid_game(
			int(mid_raw.get("level_number", 1)),
			mid_raw.get("tubes", []),
			mid_raw.get("history", []),
			int(mid_raw.get("move_count", 0)),
			int(mid_raw.get("capacity", 4))
		)
	else:
		clear_mid_game()
	return true

static func write_export_file(path: String = EXPORT_PATH) -> Error:
	var text: String = JSON.stringify(build_export_dict(), "\t")
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(text)
	return OK

static func read_import_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return apply_import_dict(parsed)

static func _previous_utc_date_key(date_key: String) -> String:
	var key: String = date_key.strip_edges()
	if key.length() != 8 or not key.is_valid_int():
		return ""
	var y: int = int(key.substr(0, 4))
	var m: int = int(key.substr(4, 2))
	var d: int = int(key.substr(6, 2))
	var noon_unix: int = int(Time.get_unix_time_from_datetime_dict({
		"year": y, "month": m, "day": d,
		"hour": 12, "minute": 0, "second": 0,
	}))
	var prev: Dictionary = Time.get_datetime_dict_from_unix_time(noon_unix - 86400)
	return "%04d%02d%02d" % [int(prev.year), int(prev.month), int(prev.day)]

static func _load_cfg() -> ConfigFile:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	return cfg

static func _write_cfg(cfg: ConfigFile) -> void:
	var err: Error = cfg.save(PATH)
	if err != OK:
		push_warning("SaveService: failed to write %s (err %s)" % [PATH, err])

static func _infer_capacity(history, tubes) -> int:
	if history is Array and not history.is_empty() and history[0] is Dictionary:
		return int(history[0].get("capacity", 4))
	# Fallback: longest tube length (at least 4).
	var cap: int = 4
	if tubes is Array:
		for colors in tubes:
			if colors is Array:
				cap = maxi(cap, colors.size())
	return cap

static func _deep_copy(value: Variant) -> Variant:
	if value is Array:
		var out: Array = []
		for item in value:
			out.append(_deep_copy(item))
		return out
	if value is Dictionary:
		var out_d: Dictionary = {}
		for key in value:
			out_d[key] = _deep_copy(value[key])
		return out_d
	return value
