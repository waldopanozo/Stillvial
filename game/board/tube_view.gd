class_name TubeView
extends Control

signal pressed(index: int)

const TUBE_WIDTH := 56.0
const TUBE_HEIGHT := 200.0
const PAD := 6.0

var tube_index: int = -1
var capacity: int = 4
## Patterns are first-class a11y (default on); set from BoardView / settings.
var patterns_enabled: bool = true

var _layers: Array[LiquidBand] = []
var _selected: bool = false
var _tip: bool = false
var _specular: ColorRect = null

@onready var _glass: Panel = $Glass
@onready var _layers_root: Control = $Layers
@onready var _highlight: ColorRect = $Highlight
@onready var _button: Button = $Hit

func _ready() -> void:
	custom_minimum_size = Vector2(TUBE_WIDTH + 12.0, TUBE_HEIGHT + 16.0)
	_button.pressed.connect(_on_hit)
	_make_hit_invisible()
	_highlight.visible = false
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Sit behind glass/liquid; match vial footprint for calmer edges.
	_highlight.position = Vector2(PAD, 8.0)
	_highlight.size = Vector2(TUBE_WIDTH, TUBE_HEIGHT)
	_style_glass()

## Transparent hit target — no Button/Secondary outline chrome on hover/focus.
func _make_hit_invisible() -> void:
	_button.flat = true
	var empty := StyleBoxFlat.new()
	empty.bg_color = Color(0, 0, 0, 0)
	empty.draw_center = false
	empty.set_border_width_all(0)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		_button.add_theme_stylebox_override(state, empty.duplicate())

func setup(index: int, tube: Tube) -> void:
	tube_index = index
	refresh(tube)

func set_patterns_enabled(on: bool) -> void:
	patterns_enabled = on
	for band in _layers:
		band.patterns_enabled = on
		band.queue_redraw()

func refresh(tube: Tube) -> void:
	capacity = tube.capacity
	_ensure_layers(capacity)
	var slot_h: float = _slot_height()
	for i in _layers.size():
		var band: LiquidBand = _layers[i]
		if i >= capacity:
			band.visible = false
			continue
		band.position = Vector2(PAD, TUBE_HEIGHT - PAD - float(i + 1) * slot_h)
		band.size = Vector2(TUBE_WIDTH - PAD * 2.0, slot_h - 1.0)
		band.patterns_enabled = patterns_enabled
		if i < tube.colors.size():
			band.set_color_id(tube.colors[i])
			band.visible = true
		else:
			band.set_color_id(-1)
			band.visible = false

func set_selected(on: bool) -> void:
	_selected = on
	_sync_highlight()

func set_tip_highlighted(on: bool) -> void:
	_tip = on
	_sync_highlight()

func is_selected() -> bool:
	return _selected

func _sync_highlight() -> void:
	if _selected:
		_highlight.color = Palette.selection()
		_highlight.modulate.a = 0.32
		_highlight.visible = true
	elif _tip:
		_highlight.color = Palette.tip_highlight()
		_highlight.modulate.a = 0.28
		_highlight.visible = true
	else:
		_highlight.visible = false

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
	var band: LiquidBand = _layers[slot]
	return Rect2(band.global_position, band.size)

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
		var band := LiquidBand.new()
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.patterns_enabled = patterns_enabled
		_layers_root.add_child(band)
		_layers.append(band)
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
	_ensure_specular()
	_sync_highlight()

## Thin static left-edge mist line (no animation; OK under Low effects).
func _ensure_specular() -> void:
	if _specular != null and is_instance_valid(_specular):
		return
	_specular = ColorRect.new()
	_specular.name = "Specular"
	_specular.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_specular.color = Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.2)
	_specular.position = Vector2(5.0, 14.0)
	_specular.size = Vector2(2.5, TUBE_HEIGHT - 36.0)
	_glass.add_child(_specular)

func _on_hit() -> void:
	pressed.emit(tube_index)


## One liquid slot: solid fill + optional accessibility pattern.
class LiquidBand extends Control:
	var color_id: int = -1
	var patterns_enabled: bool = true

	func set_color_id(id: int) -> void:
		color_id = id
		queue_redraw()

	func _draw() -> void:
		if color_id < 0:
			return
		Palette.draw_liquid_band(self, size, color_id, patterns_enabled)
