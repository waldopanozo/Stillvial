class_name PourRules
extends RefCounted

static func can_pour(from: Tube, to: Tube) -> bool:
	if from == null or to == null:
		return false
	if from.is_empty() or to.is_full():
		return false
	if from == to:
		return false
	var color: int = from.top_color()
	if color == WaterColor.EMPTY:
		return false
	if not to.is_empty() and to.top_color() != color:
		return false
	var amount: int = mini(from.top_run_length(), to.free_space())
	return amount > 0

static func apply_pour(from: Tube, to: Tube) -> int:
	if not can_pour(from, to):
		return 0
	var color: int = from.top_color()
	var amount: int = mini(from.top_run_length(), to.free_space())
	for _i in amount:
		from.colors.pop_back()
		to.colors.append(color)
	return amount
