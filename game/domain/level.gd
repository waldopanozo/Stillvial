class_name Level
extends RefCounted

var level_number: int = 0
var tubes: Array[Tube] = []
var move_count: int = 0

func _init(p_level_number: int = 0, p_tubes: Array = [], p_move_count: int = 0) -> void:
	level_number = p_level_number
	tubes = []
	for t in p_tubes:
		if t is Tube:
			tubes.append(t)
		else:
			push_error("Level expects Tube instances")
	move_count = p_move_count

func is_complete() -> bool:
	for t in tubes:
		if not t.is_solved():
			return false
	return true

func color_count() -> int:
	var seen: Dictionary = {}
	for t in tubes:
		for c in t.colors:
			seen[c] = true
	return seen.size()

func capacity() -> int:
	if tubes.is_empty():
		return 0
	return tubes[0].capacity

func try_pour(from_index: int, to_index: int) -> int:
	if from_index < 0 or to_index < 0:
		return 0
	if from_index >= tubes.size() or to_index >= tubes.size():
		return 0
	var moved: int = PourRules.apply_pour(tubes[from_index], tubes[to_index])
	if moved > 0:
		move_count += 1
	return moved

func tube_color_arrays() -> Array:
	var out: Array = []
	for t in tubes:
		out.append(t.colors.duplicate())
	return out

func duplicate_level() -> Level:
	var copies: Array[Tube] = []
	for t in tubes:
		copies.append(Tube.new(t.capacity, t.colors.duplicate()))
	return Level.new(level_number, copies, move_count)
