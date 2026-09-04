class_name LevelSolver
extends RefCounted

## Finds one next pour toward a solved board. Uses BFS with a state cap.
## Returns Vector2i(from_index, to_index) or null.

const DEFAULT_STATE_LIMIT: int = 40000

static func next_pour(level: Level, state_limit: int = DEFAULT_STATE_LIMIT) -> Variant:
	if level == null or level.tubes.is_empty():
		return null
	if level.is_complete():
		return null

	var start: Array = _clone_colors(level.tubes)
	var capacity: int = level.capacity()
	var n: int = start.size()
	var visited: Dictionary = {}
	visited[_key(start)] = true

	## Queue entries: { "tubes": Array, "first": Vector2i } — first is the root pour.
	var queue: Array = []
	var explored: int = 1

	for move in _legal_moves(start, capacity):
		var from_i: int = move.x
		var to_i: int = move.y
		var nxt: Array = _clone_state(start)
		if _apply_on_arrays(nxt, from_i, to_i, capacity) <= 0:
			continue
		var k: String = _key(nxt)
		if visited.has(k):
			continue
		visited[k] = true
		explored += 1
		var first := Vector2i(from_i, to_i)
		if _arrays_complete(nxt, capacity):
			return first
		queue.append({"tubes": nxt, "first": first})

	var qi: int = 0
	while qi < queue.size() and explored < state_limit:
		var node: Dictionary = queue[qi]
		qi += 1
		var tubes: Array = node["tubes"]
		var first: Vector2i = node["first"]
		for move in _legal_moves(tubes, capacity):
			if explored >= state_limit:
				break
			var nxt2: Array = _clone_state(tubes)
			if _apply_on_arrays(nxt2, move.x, move.y, capacity) <= 0:
				continue
			var k2: String = _key(nxt2)
			if visited.has(k2):
				continue
			visited[k2] = true
			explored += 1
			if _arrays_complete(nxt2, capacity):
				return first
			queue.append({"tubes": nxt2, "first": first})

	return null

static func _clone_colors(tubes: Array[Tube]) -> Array:
	var out: Array = []
	for t in tubes:
		out.append(t.colors.duplicate())
	return out

static func _clone_state(state: Array) -> Array:
	var out: Array = []
	for colors in state:
		out.append((colors as Array).duplicate())
	return out

static func _key(state: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for colors in state:
		var inner: PackedStringArray = PackedStringArray()
		for c in colors:
			inner.append(str(int(c)))
		parts.append(",".join(inner))
	return "|".join(parts)

static func _arrays_complete(state: Array, capacity: int) -> bool:
	for colors in state:
		var arr: Array = colors
		if arr.is_empty():
			continue
		if arr.size() != capacity:
			return false
		var first: int = int(arr[0])
		for c in arr:
			if int(c) != first:
				return false
	return true

static func _legal_moves(state: Array, capacity: int) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	var n: int = state.size()
	for from_i in n:
		var from_colors: Array = state[from_i]
		if from_colors.is_empty():
			continue
		var from_t := Tube.new(capacity, from_colors)
		for to_i in n:
			if from_i == to_i:
				continue
			var to_t := Tube.new(capacity, state[to_i])
			if PourRules.can_pour(from_t, to_t):
				moves.append(Vector2i(from_i, to_i))
	return moves

static func _apply_on_arrays(state: Array, from_i: int, to_i: int, capacity: int) -> int:
	var from_t := Tube.new(capacity, state[from_i])
	var to_t := Tube.new(capacity, state[to_i])
	var moved: int = PourRules.apply_pour(from_t, to_t)
	if moved > 0:
		state[from_i] = from_t.colors.duplicate()
		state[to_i] = to_t.colors.duplicate()
	return moved
