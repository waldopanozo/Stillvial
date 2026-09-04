class_name Tube
extends RefCounted

## colors[0] = bottom, colors[last] = top.
var capacity: int
var colors: Array[int] = []

func _init(p_capacity: int = 4, p_colors: Array = []) -> void:
	capacity = p_capacity
	colors = []
	for c in p_colors:
		colors.append(int(c))

func is_empty() -> bool:
	return colors.is_empty()

func is_full() -> bool:
	return colors.size() >= capacity

func free_space() -> int:
	return capacity - colors.size()

func is_solved() -> bool:
	if is_empty():
		return true
	if colors.size() != capacity:
		return false
	var first: int = colors[0]
	for c in colors:
		if c != first:
			return false
	return true

func top_color() -> int:
	if is_empty():
		return WaterColor.EMPTY
	return colors[colors.size() - 1]

func top_run_length() -> int:
	if is_empty():
		return 0
	var top: int = top_color()
	var n: int = 0
	var i: int = colors.size() - 1
	while i >= 0 and colors[i] == top:
		n += 1
		i -= 1
	return n
