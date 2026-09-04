class_name GameHud
extends MarginContainer

signal undo_pressed
signal reset_pressed
signal home_pressed

@onready var _level_label: Label = $VBox/TopRow/LevelLabel
@onready var _moves_label: Label = $VBox/TopRow/MovesLabel
@onready var _undo_btn: Button = $VBox/Buttons/UndoButton
@onready var _reset_btn: Button = $VBox/Buttons/ResetButton
@onready var _tip_btn: Button = $VBox/Buttons/TipButton
@onready var _home_btn: Button = $VBox/Buttons/HomeButton

var _undo_allowed: bool = false
var _controls_on: bool = true

func _ready() -> void:
	var mist := Palette.MIST
	_level_label.add_theme_color_override("font_color", mist)
	_moves_label.add_theme_color_override("font_color", mist)
	_undo_btn.pressed.connect(func() -> void: undo_pressed.emit())
	_reset_btn.pressed.connect(func() -> void: reset_pressed.emit())
	_home_btn.pressed.connect(func() -> void: home_pressed.emit())
	# Tips arrive in Task 7.
	_tip_btn.disabled = true
	_tip_btn.visible = false
	_sync_buttons()

func set_level_number(n: int) -> void:
	_level_label.text = "Level %d" % n

func set_move_count(n: int) -> void:
	_moves_label.text = "Moves %d" % n

func set_undo_enabled(enabled: bool) -> void:
	_undo_allowed = enabled
	_sync_buttons()

func set_controls_enabled(enabled: bool) -> void:
	_controls_on = enabled
	_sync_buttons()

func _sync_buttons() -> void:
	_undo_btn.disabled = not _controls_on or not _undo_allowed
	_reset_btn.disabled = not _controls_on
	_home_btn.disabled = not _controls_on
