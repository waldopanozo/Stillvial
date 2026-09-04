class_name LevelGenerator
extends RefCounted

const BASE_COLORS: int = 3
const MAX_COLORS: int = 16
## Daily puzzles sit in the tip-eligible band (campaign ≥10).
const DAILY_LEVEL_MIN: int = 10
const DAILY_LEVEL_SPAN: int = 21

static func generate(level_number: int) -> Level:
	return _generate_with_seed(level_number, level_number, level_number)

## Shared UTC daily puzzle. `date_key` is `YYYYMMDD` (e.g. "20260904").
static func generate_daily(date_key: String) -> Level:
	var seed_i: int = date_key_to_seed(date_key)
	var params_level: int = DAILY_LEVEL_MIN + (absi(seed_i) % DAILY_LEVEL_SPAN)
	return _generate_with_seed(seed_i, params_level, 0)

static func date_key_to_seed(date_key: String) -> int:
	var cleaned: String = date_key.strip_edges()
	if cleaned.is_valid_int():
		return int(cleaned)
	return cleaned.hash()

static func _generate_with_seed(rng_seed: int, params_level: int, level_number: int) -> Level:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed

	var colors: int = color_count_for(params_level)
	var cap: int = capacity_for(params_level)
	var empties: int = empty_count_for(colors)

	var tubes: Array[Tube] = []
	for c in range(colors):
		var filled: Array[int] = []
		for _i in cap:
			filled.append(c)
		tubes.append(Tube.new(cap, filled))
	for _e in empties:
		tubes.append(Tube.new(cap, []))

	var scramble_steps: int = maxi(colors * cap * 4, 16)
	_scramble_unit_pours(tubes, rng, scramble_steps)

	var guard: int = 0
	while _all_solved(tubes) and guard < 64:
		_scramble_unit_pours(tubes, rng, colors * cap * 2)
		guard += 1

	return Level.new(level_number, tubes, 0)

static func color_count_for(level_number: int) -> int:
	var count: int = BASE_COLORS + int((level_number - 1) / 3)
	return clampi(count, BASE_COLORS, MAX_COLORS)

static func capacity_for(level_number: int) -> int:
	if level_number % 10 == 0:
		return 6
	if level_number % 5 == 0:
		return 5
	return 4

static func empty_count_for(color_count: int) -> int:
	if color_count <= 4:
		return 1
	if color_count <= 12:
		return 2
	return 3

static func _all_solved(tubes: Array[Tube]) -> bool:
	for t in tubes:
		if not t.is_solved():
			return false
	return true

## Move one unit at a time under pour color/space rules so the board
## stays solvable (units can be poured back into mono tubes).
static func _scramble_unit_pours(tubes: Array[Tube], rng: RandomNumberGenerator, steps: int) -> void:
	var n: int = tubes.size()
	for _s in steps:
		var candidates: Array = []
		for from_i in n:
			var from_t: Tube = tubes[from_i]
			if from_t.is_empty():
				continue
			var color: int = from_t.top_color()
			for to_i in n:
				if from_i == to_i:
					continue
				var to_t: Tube = tubes[to_i]
				if to_t.is_full():
					continue
				if not to_t.is_empty() and to_t.top_color() != color:
					continue
				# Avoid relocating a lone unit into a vacant tube (no progress).
				if to_t.is_empty() and from_t.colors.size() == 1:
					continue
				candidates.append([from_i, to_i])
		if candidates.is_empty():
			break
		var pick: Array = candidates[rng.randi_range(0, candidates.size() - 1)]
		var from_t: Tube = tubes[pick[0]]
		var to_t: Tube = tubes[pick[1]]
		var color: int = from_t.top_color()
		from_t.colors.pop_back()
		to_t.colors.append(color)
