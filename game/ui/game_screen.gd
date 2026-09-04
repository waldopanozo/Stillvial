extends Control

## Campaign match: BoardView + HUD, undo history, reset, calm win.

@onready var _board: BoardView = $BoardView
@onready var _hud: GameHud = $Hud
@onready var _win_panel: PanelContainer = $WinLayer/Center/Panel
@onready var _win_label: Label = $WinLayer/Center/Panel/VBox/WinLabel
@onready var _win_next: Button = $WinLayer/Center/Panel/VBox/NextButton
@onready var _win_home: Button = $WinLayer/Center/Panel/VBox/HomeButton
@onready var _win_layer: CanvasLayer = $WinLayer

var _level_number: int = 1
## Snapshots before each successful pour: { "tubes": Array, "moves": int }
var _history: Array = []
var _pre_pour: Dictionary = {}
var _won: bool = false

func _ready() -> void:
	_level_number = maxi(CampaignSession.requested_level, 1)
	_win_layer.visible = false
	_win_label.text = "Order restored"
	_win_label.add_theme_color_override("font_color", Palette.MIST)
	_hud.undo_pressed.connect(_on_undo)
	_hud.reset_pressed.connect(_on_reset)
	_hud.home_pressed.connect(_go_home)
	_win_next.pressed.connect(_on_next_level)
	_win_home.pressed.connect(_go_home)
	_board.pour_finished.connect(_on_pour_finished)
	_board.level_completed.connect(_on_level_completed)
	_start_level(_level_number)

func _start_level(level_number: int) -> void:
	_won = false
	_win_layer.visible = false
	_level_number = level_number
	_history.clear()
	var level: Level = LevelGenerator.generate(_level_number)
	_board.load_level(level)
	_pre_pour = _make_snapshot()
	_hud.set_level_number(_level_number)
	_hud.set_move_count(0)
	_hud.set_undo_enabled(false)
	_hud.set_controls_enabled(true)

func _make_snapshot() -> Dictionary:
	var level: Level = _board.get_level()
	if level == null:
		return {"tubes": [], "moves": 0, "capacity": 4}
	return {
		"tubes": level.tube_color_arrays(),
		"moves": level.move_count,
		"capacity": level.capacity(),
	}

func _restore_snapshot(snap: Dictionary) -> void:
	var cap: int = int(snap.get("capacity", 4))
	var tubes: Array[Tube] = []
	for colors in snap["tubes"]:
		tubes.append(Tube.new(cap, colors))
	var restored := Level.new(_level_number, tubes, int(snap["moves"]))
	_board.load_level(restored)

func _on_pour_finished(_from: int, _to: int, amount: int) -> void:
	if amount <= 0:
		return
	_history.append(_pre_pour)
	_pre_pour = _make_snapshot()
	var level: Level = _board.get_level()
	if level:
		_hud.set_move_count(level.move_count)
	_hud.set_undo_enabled(not _history.is_empty())

func _on_undo() -> void:
	if _won or _board.is_busy() or _history.is_empty():
		return
	var snap: Dictionary = _history.pop_back()
	_restore_snapshot(snap)
	_pre_pour = _make_snapshot()
	_hud.set_move_count(int(snap["moves"]))
	_hud.set_undo_enabled(not _history.is_empty())

func _on_reset() -> void:
	if _won or _board.is_busy():
		return
	_start_level(_level_number)

func _on_level_completed() -> void:
	if _won:
		return
	_won = true
	CampaignSession.register_win(_level_number)
	_hud.set_controls_enabled(false)
	_hud.set_undo_enabled(false)
	_win_next.text = "Level %d" % CampaignSession.campaign_level
	_win_layer.visible = true

func _on_next_level() -> void:
	CampaignSession.request_play(CampaignSession.campaign_level)
	_start_level(CampaignSession.requested_level)

func _go_home() -> void:
	get_tree().change_scene_to_file("res://ui/home.tscn")
