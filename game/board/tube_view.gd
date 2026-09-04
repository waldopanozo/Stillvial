class_name TubeView
extends Control

signal pressed(index: int)

const TUBE_WIDTH := 56.0
const TUBE_HEIGHT := 200.0
const PAD := 6.0

var tube_index: int = -1
var capacity: int = 4

var _layers: Array[ColorRect] = []
var _selected: bool = false

@onready var _glass: Panel = $Glass
@onready var _layers_root: Control = $Layers
@onready var _highlight: ColorRect = $Highlight
@onready var _button: Button = $Hit

func _ready() -> void:
	custom_minimum_size = Vector2(TUBE_WIDTH + 12.0, TUBE_HEIGHT + 16.0)
	_button.pressed.connect(_on_hit)
	_highlight.visible = false
	_style_glass()

func setup(index: int, tube: Tube) -> void:
	tube_index = index
	refresh(tube)

func refresh(tube: Tube) -> void:
	capacity = tube.capacity
	_ensure_layers(capacity)
	var slot_h: float = _slot_height()
	for i in _layers.size():
		var rect: ColorRect = _layers[i]
		if i >= capacity:
			rect.visible = false
			continue
		rect.position = Vector2(PAD, TUBE_HEIGHT - PAD - float(i + 1) * slot_h)
		rect.size = Vector2(TUBE_WIDTH - PAD * 2.0, slot_h - 1.0)
		if i < tube.colors.size():
			rect.color = Palette.water(tube.colors[i])
			rect.visible = true
		else:
			rect.visible = false

func set_selected(on: bool) -> void:
	_selected = on
	_highlight.visible = on

func is_selected() -> bool:
	return _selected

## Global rect of the topmost visible water segment (for pour tween).
func top_segment_global_rect() -> Rect2:
	var top_i: int = -1
	for i in range(_layers.size() - 1, -1, -1):
		if _layers[i].visible:
			top_i = i
			break
	if top_i < 0:
		return get_global_rect()
	return _layers[top_i].get_global_rect()

## Where incoming water should land (next empty slot from bottom).
func next_empty_global_rect(tube: Tube) -> Rect2:
	var slot: int = tube.colors.size()
	slot = clampi(slot, 0, maxi(capacity - 1, 0))
	_ensure_layers(capacity)
	var rect: ColorRect = _layers[slot]
	return Rect2(rect.global_position, rect.size)

func hide_top_units(count: int) -> void:
	var hidden: int = 0
	for i in range(_layers.size() - 1, -1, -1):
		if hidden >= count:
			break
		if _layers[i].visible:
			_layers[i].visible = false
			hidden += 1

func _slot_height() -> float:
	var inner: float = TUBE_HEIGHT - PAD * 2.0
	return inner / float(maxi(capacity, 1))

func _ensure_layers(cap: int) -> void:
	while _layers.size() < cap:
		var r := ColorRect.new()
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_layers_root.add_child(r)
		_layers.append(r)
	for i in _layers.size():
		_layers[i].visible = i < cap and _layers[i].visible

func _style_glass() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Palette.glass_fill()
	sb.border_color = Palette.glass_stroke()
	sb.set_border_width_all(2)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 18
	sb.corner_radius_bottom_right = 18
	_glass.add_theme_stylebox_override("panel", sb)
	_highlight.color = Palette.selection()
	_highlight.modulate.a = 0.35

func _on_hit() -> void:
	pressed.emit(tube_index)
