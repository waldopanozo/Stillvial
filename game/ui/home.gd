extends Control

## Stillvial home — campaign, daily, accessibility toggles, guest backup.

@onready var _title: Label = $Center/VBox/Title
@onready var _tagline: Label = $Center/VBox/Tagline
@onready var _continue_btn: Button = $Center/VBox/ContinueButton
@onready var _play_btn: Button = $Center/VBox/PlayButton
@onready var _daily_btn: Button = $Center/VBox/DailyButton
@onready var _streak_label: Label = $Center/VBox/StreakLabel
@onready var _export_btn: Button = $Center/VBox/Backup/ExportButton
@onready var _import_btn: Button = $Center/VBox/Backup/ImportButton
@onready var _backup_status: Label = $Center/VBox/BackupStatus
@onready var _patterns_cb: CheckButton = $Center/VBox/Settings/PatternsToggle
@onready var _low_effects_cb: CheckButton = $Center/VBox/Settings/LowEffectsToggle
@onready var _bg: ColorRect = $Background
@onready var _export_dialog: FileDialog = $ExportDialog
@onready var _import_dialog: FileDialog = $ImportDialog

func _ready() -> void:
	_bg.color = Palette.board_bg()
	_title.add_theme_color_override("font_color", Palette.MIST)
	_tagline.add_theme_color_override("font_color", Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.75))
	_streak_label.add_theme_color_override("font_color", Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.7))
	_backup_status.add_theme_color_override("font_color", Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.65))
	_hydrate_progress()
	_hydrate_settings()
	_refresh_labels()
	_continue_btn.pressed.connect(_on_continue)
	_play_btn.pressed.connect(_on_play_campaign)
	_daily_btn.pressed.connect(_on_play_daily)
	_export_btn.pressed.connect(_on_export)
	_import_btn.pressed.connect(_on_import)
	_patterns_cb.toggled.connect(_on_settings_changed)
	_low_effects_cb.toggled.connect(_on_settings_changed)
	_export_dialog.file_selected.connect(_on_export_path)
	_import_dialog.file_selected.connect(_on_import_path)

func _hydrate_progress() -> void:
	var progress: Dictionary = SaveService.load_progress()
	CampaignSession.apply_progress(
		int(progress.get("current_level", 1)),
		int(progress.get("max_completed", 0))
	)

func _hydrate_settings() -> void:
	var settings: Dictionary = SaveService.load_settings()
	_patterns_cb.set_pressed_no_signal(bool(settings.get(
		"patterns_enabled", SaveService.DEFAULT_PATTERNS_ENABLED
	)))
	_low_effects_cb.set_pressed_no_signal(bool(settings.get(
		"low_effects", SaveService.DEFAULT_LOW_EFFECTS
	)))
	_style_settings_labels()

func _style_settings_labels() -> void:
	var mist := Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.9)
	_patterns_cb.add_theme_color_override("font_color", mist)
	_low_effects_cb.add_theme_color_override("font_color", mist)

func _on_settings_changed(_pressed: bool = false) -> void:
	SaveService.save_settings(_patterns_cb.button_pressed, _low_effects_cb.button_pressed)

func _refresh_labels() -> void:
	var mid: Variant = SaveService.load_any_mid_game()
	var n: int = maxi(CampaignSession.campaign_level, 1)
	if mid != null:
		n = maxi(int(mid.get("level_number", n)), 1)
		_continue_btn.text = "Continue — Level %d" % n
	else:
		_continue_btn.text = "Continue — Level %d" % n
	_play_btn.text = "Play campaign"
	var today: String = SaveService.utc_date_key()
	var daily: Dictionary = SaveService.load_daily()
	var streak: int = int(daily.get("streak", 0))
	if SaveService.is_daily_completed(today):
		_daily_btn.text = "Daily — done"
	else:
		_daily_btn.text = "Daily challenge"
	if streak > 0:
		_streak_label.text = "Streak %d" % streak
		_streak_label.visible = true
	else:
		_streak_label.text = ""
		_streak_label.visible = false

func _on_continue() -> void:
	var mid: Variant = SaveService.load_any_mid_game()
	if mid != null:
		var level_number: int = maxi(int(mid.get("level_number", 1)), 1)
		_start_level(level_number, mid)
		return
	_start_level(CampaignSession.campaign_level, null)

func _on_play_campaign() -> void:
	SaveService.clear_mid_game()
	_start_level(CampaignSession.campaign_level, null)

func _on_play_daily() -> void:
	var today: String = SaveService.utc_date_key()
	CampaignSession.request_daily(today)
	get_tree().change_scene_to_file("res://ui/game_screen.tscn")

func _on_export() -> void:
	# Always write the default user path; open a save dialog when the OS allows file picking.
	var err: Error = SaveService.write_export_file(SaveService.EXPORT_PATH)
	if err != OK:
		_backup_status.text = "Could not export — try again"
		return
	_backup_status.text = "Saved backup in app data (stillvial_backup.json)"
	if OS.has_feature("pc") or OS.has_feature("editor"):
		_export_dialog.current_file = "stillvial_backup.json"
		_export_dialog.popup_centered_ratio(0.6)

func _on_export_path(path: String) -> void:
	var err: Error = SaveService.write_export_file(path)
	if err == OK:
		_backup_status.text = "Backup saved — keep this file safe"
	else:
		_backup_status.text = "Could not save to that location"

func _on_import() -> void:
	if OS.has_feature("pc") or OS.has_feature("editor"):
		_import_dialog.popup_centered_ratio(0.6)
		return
	# Mobile / constrained: import from default app-data path if present.
	if SaveService.read_import_file(SaveService.EXPORT_PATH):
		_after_import_ok()
	else:
		_backup_status.text = "No backup found in app data yet"

func _on_import_path(path: String) -> void:
	if SaveService.read_import_file(path):
		_after_import_ok()
	else:
		_backup_status.text = "That file is not a Stillvial backup"

func _after_import_ok() -> void:
	_hydrate_progress()
	_hydrate_settings()
	_refresh_labels()
	_backup_status.text = "Backup restored — take your time"

func _start_level(level_number: int, resume: Variant) -> void:
	CampaignSession.request_play(maxi(level_number, 1), resume)
	get_tree().change_scene_to_file("res://ui/game_screen.tscn")
