extends Control

## Match screen: campaign or daily; undo history, reset, tips, calm win.

const TIP_START_LEVEL: int = 10

@onready var _board: BoardView = $BoardView
@onready var _hud: GameHud = $Hud
@onready var _win_panel: PanelContainer = $WinLayer/Center/Panel
@onready var _win_label: Label = $WinLayer/Center/Panel/VBox/WinLabel
@onready var _win_next: Button = $WinLayer/Center/Panel/VBox/NextButton
@onready var _win_home: Button = $WinLayer/Center/Panel/VBox/HomeButton
@onready var _win_layer: CanvasLayer = $WinLayer

var _level_number: int = 1
var _is_daily: bool = false
var _daily_date_key: String = ""
## Snapshots before each successful pour: { "tubes": Array, "moves": int }
var _history: Array = []
var _pre_pour: Dictionary = {}
var _won: bool = false

func _ready() -> void:
	theme = ThemeFactory.build()
	$WinLayer/Center.theme = theme
	_is_daily = CampaignSession.is_daily()
	_daily_date_key = CampaignSession.daily_date_key
	_level_number = maxi(CampaignSession.requested_level, 1)
	_win_layer.visible = false
	_win_label.text = "Order restored"
	_style_win_modal()
	_apply_accessibility_settings()
	_hud.undo_pressed.connect(_on_undo)
	_hud.reset_pressed.connect(_on_reset)
	_hud.tip_pressed.connect(_on_tip)
	_hud.home_pressed.connect(_go_home)
	_win_next.pressed.connect(_on_next_level)
	_win_home.pressed.connect(_go_home)
	_board.pour_finished.connect(_on_pour_finished)
	_board.level_completed.connect(_on_level_completed)
	var resume: Variant = CampaignSession.resume_payload
	CampaignSession.resume_payload = null
	if _is_daily:
		_start_daily(_daily_date_key)
	else:
		_start_level(_level_number, resume)

func _style_win_modal() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Palette.SURFACE_RAISED
	sb.set_corner_radius_all(20)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	_win_panel.add_theme_stylebox_override("panel", sb)
	_win_next.theme_type_variation = "Primary"
	_win_home.theme_type_variation = "Ghost"
	_win_label.theme_type_variation = "Title"
	_win_label.add_theme_font_size_override("font_size", 36)

func _apply_accessibility_settings() -> void:
	var settings: Dictionary = SaveService.load_settings()
	_board.apply_settings(
		bool(settings.get("patterns_enabled", SaveService.DEFAULT_PATTERNS_ENABLED)),
		bool(settings.get("low_effects", SaveService.DEFAULT_LOW_EFFECTS))
	)

func _tips_allowed_for(level_number: int) -> bool:
	if _is_daily:
		return true
	return level_number >= TIP_START_LEVEL

func _start_daily(date_key: String) -> void:
	_won = false
	_win_layer.visible = false
	_is_daily = true
	_daily_date_key = date_key
	_level_number = 0
	_history.clear()
	_board.clear_tip_highlight()
	_hud.clear_tip_feedback()
	_hud.configure_tips(true, GameHud.TIPS_PER_PUZZLE)
	var level: Level = LevelGenerator.generate_daily(date_key)
	_board.load_level(level)
	_pre_pour = _make_snapshot()
	_hud.set_level_title("Daily")
	_hud.set_move_count(0)
	_hud.set_undo_enabled(false)
	_hud.set_controls_enabled(true)

func _start_level(level_number: int, resume: Variant = null) -> void:
	_won = false
	_win_layer.visible = false
	_is_daily = false
	_daily_date_key = ""
	_level_number = level_number
	_history.clear()
	_board.clear_tip_highlight()
	_hud.clear_tip_feedback()
	_hud.configure_tips(_tips_allowed_for(_level_number), GameHud.TIPS_PER_PUZZLE)
	if resume != null and int(resume.get("level_number", -1)) == _level_number:
		_apply_mid_game(resume)
	else:
		var level: Level = LevelGenerator.generate(_level_number)
		_board.load_level(level)
		_pre_pour = _make_snapshot()
		_hud.set_level_number(_level_number)
		_hud.set_move_count(0)
	_hud.set_undo_enabled(not _history.is_empty())
	_hud.set_controls_enabled(true)

func _apply_mid_game(payload: Dictionary) -> void:
	var capacity: int = int(payload.get("capacity", _capacity_for_level(_level_number)))
	var hist: Array = payload.get("history", [])
	if hist is Array and not hist.is_empty() and hist[0] is Dictionary:
		capacity = int(hist[0].get("capacity", capacity))
	var tubes: Array[Tube] = []
	for colors in payload.get("tubes", []):
		tubes.append(Tube.new(capacity, colors))
	var move_count: int = int(payload.get("move_count", 0))
	var restored := Level.new(_level_number, tubes, move_count)
	_board.load_level(restored)
	_history.clear()
	if hist is Array:
		for snap in hist:
			if snap is Dictionary:
				_history.append(snap.duplicate(true))
	_pre_pour = _make_snapshot()
	_hud.set_level_number(_level_number)
	_hud.set_move_count(move_count)

func _capacity_for_level(level_number: int) -> int:
	return LevelGenerator.generate(level_number).capacity()

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

func _persist_mid_game() -> void:
	if _is_daily:
		return
	var level: Level = _board.get_level()
	if level == null:
		return
	SaveService.save_mid_game(
		_level_number,
		level.tube_color_arrays(),
		_history.duplicate(true),
		level.move_count,
		level.capacity()
	)

func _on_pour_finished(_from: int, _to: int, amount: int) -> void:
	if amount <= 0:
		return
	_board.clear_tip_highlight()
	_history.append(_pre_pour)
	_pre_pour = _make_snapshot()
	var level: Level = _board.get_level()
	if level:
		_hud.set_move_count(level.move_count)
	_hud.set_undo_enabled(not _history.is_empty())
	if not _won:
		_persist_mid_game()

func _on_undo() -> void:
	if _won or _board.is_busy() or _history.is_empty():
		return
	_board.clear_tip_highlight()
	_hud.clear_tip_feedback()
	var snap: Dictionary = _history.pop_back()
	_restore_snapshot(snap)
	_pre_pour = _make_snapshot()
	_hud.set_move_count(int(snap["moves"]))
	_hud.set_undo_enabled(not _history.is_empty())
	# Undo does not refill tips.
	_persist_mid_game()

func _on_reset() -> void:
	if _won or _board.is_busy():
		return
	if _is_daily:
		_start_daily(_daily_date_key)
		return
	SaveService.clear_mid_game()
	_start_level(_level_number, null)
	# _start_level refills tips via configure_tips.

func _on_tip() -> void:
	if _won or _board.is_busy():
		return
	if not _hud.tips_enabled() or _hud.tips_remaining() <= 0:
		return
	var level: Level = _board.get_level()
	if level == null:
		return
	var hint: Variant = LevelSolver.next_pour(level)
	if hint == null:
		# Failed tip does not consume; calm, optional feedback.
		_hud.show_tip_feedback("No tip right now — take your time")
		_board.clear_tip_highlight()
		return
	var from_i: int = int(hint.x)
	var to_i: int = int(hint.y)
	_hud.consume_tip()
	_hud.clear_tip_feedback()
	_board.show_tip_highlight(from_i, to_i)

func _on_level_completed() -> void:
	if _won:
		return
	_won = true
	_board.clear_tip_highlight()
	_hud.set_controls_enabled(false)
	_hud.set_undo_enabled(false)
	if _is_daily:
		var result: Dictionary = SaveService.register_daily_clear(_daily_date_key)
		var streak: int = int(result.get("streak", 0))
		_win_label.text = "Order restored"
		_win_next.visible = false
		_win_home.text = "Home · streak %d" % streak
		_win_layer.visible = true
		return
	CampaignSession.register_win(_level_number)
	SaveService.clear_mid_game()
	SaveService.save_progress(CampaignSession.campaign_level, CampaignSession.max_completed)
	_win_next.visible = true
	_win_next.text = "Level %d" % CampaignSession.campaign_level
	_win_home.text = "Home"
	_win_layer.visible = true

func _on_next_level() -> void:
	if _is_daily:
		_go_home()
		return
	CampaignSession.request_play(CampaignSession.campaign_level, null)
	_start_level(CampaignSession.requested_level, null)

func _go_home() -> void:
	if not _won and not _is_daily:
		_persist_mid_game()
	get_tree().change_scene_to_file("res://ui/home.tscn")
