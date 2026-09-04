class_name SaveService
extends RefCounted

## Local campaign progress + mid-game resume (ConfigFile, no network).

const PATH := "user://stillvial_save.cfg"
const SECTION_PROGRESS := "progress"
const SECTION_MID := "mid_game"

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
