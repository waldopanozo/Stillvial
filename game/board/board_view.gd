class_name BoardView
extends Control

signal tube_selected(index: int)
signal pour_finished(from_index: int, to_index: int, amount: int)
signal level_completed

const TUBE_SCENE := preload("res://board/tube_view.tscn")

## When true, skips optional splash flash after pour.
@export var low_effects: bool = false
## Patterns are first-class a11y (default on).
@export var patterns_enabled: bool = true

var _level: Level
var _selected: int = -1
var _tip_from: int = -1
var _tip_to: int = -1
var _busy: bool = false
var _tube_views: Array[TubeView] = []

@onready var _bg: ColorRect = $Background
@onready var _row: HFlowContainer = $Margin/Row
@onready var _overlay: Control = $Overlay
@onready var _pour: PourAnimator = $PourAnimator

func _ready() -> void:
	_bg.color = Palette.board_bg()
	_pour.low_effects = low_effects
	_pour.patterns_enabled = patterns_enabled
	_pour.overlay = _overlay

## Apply persisted settings (Home toggles / resume).
func apply_settings(patterns: bool, low: bool) -> void:
	patterns_enabled = patterns
	low_effects = low
	_pour.low_effects = low
	_pour.patterns_enabled = patterns
	for v in _tube_views:
		v.set_patterns_enabled(patterns)

func load_level(level: Level) -> void:
	_level = level
	_selected = -1
	_tip_from = -1
	_tip_to = -1
	_busy = false
	_clear_tubes()
	if _level == null:
		return
	for i in _level.tubes.size():
		var view: TubeView = TUBE_SCENE.instantiate()
		_row.add_child(view)
		view.patterns_enabled = patterns_enabled
		view.setup(i, _level.tubes[i])
		view.pressed.connect(_on_tube_pressed)
		_tube_views.append(view)

func get_level() -> Level:
	return _level

func is_busy() -> bool:
	return _busy

func clear_selection() -> void:
	_selected = -1
	_sync_selection()

func show_tip_highlight(from_index: int, to_index: int) -> void:
	_tip_from = from_index
	_tip_to = to_index
	_selected = -1
	_sync_selection()

func clear_tip_highlight() -> void:
	if _tip_from < 0 and _tip_to < 0:
		return
	_tip_from = -1
	_tip_to = -1
	_sync_selection()

func _clear_tubes() -> void:
	for v in _tube_views:
		if is_instance_valid(v):
			v.queue_free()
	_tube_views.clear()
	for child in _row.get_children():
		child.queue_free()

func _on_tube_pressed(index: int) -> void:
	if _busy or _level == null:
		return
	if index < 0 or index >= _level.tubes.size():
		return

	clear_tip_highlight()
	tube_selected.emit(index)

	if _selected < 0:
		if _level.tubes[index].is_empty():
			return
		_selected = index
		_sync_selection()
		return

	if _selected == index:
		clear_selection()
		return

	var from_i: int = _selected
	var to_i: int = index
	var from_t: Tube = _level.tubes[from_i]
	var to_t: Tube = _level.tubes[to_i]
	if not PourRules.can_pour(from_t, to_t):
		# Retarget: treat new tap as source if non-empty.
		if not to_t.is_empty():
			_selected = to_i
			_sync_selection()
		else:
			clear_selection()
		return

	_begin_pour(from_i, to_i)

func _begin_pour(from_i: int, to_i: int) -> void:
	var from_t: Tube = _level.tubes[from_i]
	var to_t: Tube = _level.tubes[to_i]
	var color_id: int = from_t.top_color()
	var amount: int = mini(from_t.top_run_length(), to_t.free_space())
	if amount <= 0:
		clear_selection()
		return

	_busy = true
	_pour.low_effects = low_effects
	_pour.patterns_enabled = patterns_enabled
	_pour.animate_pour(
		_tube_views[from_i],
		_tube_views[to_i],
		color_id,
		amount,
		to_t,
		func() -> void:
			_finish_pour(from_i, to_i)
	)

func _finish_pour(from_i: int, to_i: int) -> void:
	var moved: int = PourRules.apply_pour(_level.tubes[from_i], _level.tubes[to_i])
	if moved > 0:
		_level.move_count += 1
	_refresh_all()
	_selected = -1
	_sync_selection()
	_busy = false
	pour_finished.emit(from_i, to_i, moved)
	if _level.is_complete():
		level_completed.emit()

func _refresh_all() -> void:
	for i in _tube_views.size():
		_tube_views[i].refresh(_level.tubes[i])

func _sync_selection() -> void:
	for i in _tube_views.size():
		_tube_views[i].set_selected(i == _selected)
		_tube_views[i].set_tip_highlighted(i == _tip_from or i == _tip_to)
