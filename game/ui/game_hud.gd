class_name GameHud
extends MarginContainer

signal undo_pressed
signal reset_pressed
signal tip_pressed
signal home_pressed

const TIPS_PER_PUZZLE: int = 3

@onready var _level_label: Label = $VBox/TopRow/LevelLabel
@onready var _moves_label: Label = $VBox/TopRow/MovesLabel
@onready var _undo_btn: Button = $VBox/Buttons/UndoButton
@onready var _reset_btn: Button = $VBox/Buttons/ResetButton
@onready var _tip_btn: Button = $VBox/Buttons/TipButton
@onready var _home_btn: Button = $VBox/Buttons/HomeButton
@onready var _vbox: VBoxContainer = $VBox

var _undo_allowed: bool = false
var _controls_on: bool = true
var _tips_feature_on: bool = false
var _tips_remaining: int = 0
var _tip_status: Label
var _tip_feedback_timer: Timer

func _ready() -> void:
	var mist := Palette.MIST
	_level_label.add_theme_color_override("font_color", mist)
	_moves_label.add_theme_color_override("font_color", mist)
	_undo_btn.pressed.connect(func() -> void: undo_pressed.emit())
	_reset_btn.pressed.connect(func() -> void: reset_pressed.emit())
	_tip_btn.pressed.connect(func() -> void: tip_pressed.emit())
	_home_btn.pressed.connect(func() -> void: home_pressed.emit())
	_ensure_tip_status()
	_tips_feature_on = false
	_tips_remaining = 0
	_sync_tip_ui()
	_sync_buttons()

func set_level_number(n: int) -> void:
	_level_label.text = "Level %d" % n

func set_level_title(title: String) -> void:
	_level_label.text = title

func set_move_count(n: int) -> void:
	_moves_label.text = "Moves %d" % n

func set_undo_enabled(enabled: bool) -> void:
	_undo_allowed = enabled
	_sync_buttons()

func set_controls_enabled(enabled: bool) -> void:
	_controls_on = enabled
	_sync_buttons()

## Campaign 1–9: tips off. ≥10 (and Daily/Random later): 3 tips.
func configure_tips(enabled: bool, remaining: int = TIPS_PER_PUZZLE) -> void:
	_tips_feature_on = enabled
	_tips_remaining = remaining if enabled else 0
	clear_tip_feedback()
	_sync_tip_ui()
	_sync_buttons()

func tips_enabled() -> bool:
	return _tips_feature_on

func tips_remaining() -> int:
	return _tips_remaining

func consume_tip() -> void:
	if _tips_remaining > 0:
		_tips_remaining -= 1
	_sync_tip_ui()
	_sync_buttons()

func refill_tips() -> void:
	if _tips_feature_on:
		_tips_remaining = TIPS_PER_PUZZLE
	_sync_tip_ui()
	_sync_buttons()

func show_tip_feedback(message: String) -> void:
	_ensure_tip_status()
	_tip_status.text = message
	_tip_status.visible = not message.is_empty()
	if _tip_feedback_timer:
		_tip_feedback_timer.stop()
		if not message.is_empty():
			_tip_feedback_timer.start()

func clear_tip_feedback() -> void:
	if _tip_status:
		_tip_status.text = ""
		_tip_status.visible = false
	if _tip_feedback_timer:
		_tip_feedback_timer.stop()

func _ensure_tip_status() -> void:
	if _tip_status != null:
		return
	_tip_status = Label.new()
	_tip_status.name = "TipStatus"
	_tip_status.visible = false
	_tip_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tip_status.add_theme_font_size_override("font_size", 16)
	_tip_status.add_theme_color_override("font_color", Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.75))
	_vbox.add_child(_tip_status)
	_tip_feedback_timer = Timer.new()
	_tip_feedback_timer.name = "TipFeedbackTimer"
	_tip_feedback_timer.one_shot = true
	_tip_feedback_timer.wait_time = 2.8
	_tip_feedback_timer.timeout.connect(clear_tip_feedback)
	add_child(_tip_feedback_timer)

func _sync_tip_ui() -> void:
	_tip_btn.visible = _tips_feature_on
	if _tips_feature_on:
		_tip_btn.text = "Tip %d" % _tips_remaining
	else:
		_tip_btn.text = "Tip"

func _sync_buttons() -> void:
	_undo_btn.disabled = not _controls_on or not _undo_allowed
	_reset_btn.disabled = not _controls_on
	_home_btn.disabled = not _controls_on
	_tip_btn.disabled = (
		not _controls_on
		or not _tips_feature_on
		or _tips_remaining <= 0
	)
