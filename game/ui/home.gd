extends Control

## Stillvial home — campaign entry (zen, no timer).

@onready var _title: Label = $Center/VBox/Title
@onready var _tagline: Label = $Center/VBox/Tagline
@onready var _continue_btn: Button = $Center/VBox/ContinueButton
@onready var _play_btn: Button = $Center/VBox/PlayButton
@onready var _bg: ColorRect = $Background

func _ready() -> void:
	_bg.color = Palette.board_bg()
	_title.add_theme_color_override("font_color", Palette.MIST)
	_tagline.add_theme_color_override("font_color", Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.75))
	_hydrate_progress()
	_refresh_labels()
	_continue_btn.pressed.connect(_on_continue)
	_play_btn.pressed.connect(_on_play_campaign)

func _hydrate_progress() -> void:
	var progress: Dictionary = SaveService.load_progress()
	CampaignSession.apply_progress(
		int(progress.get("current_level", 1)),
		int(progress.get("max_completed", 0))
	)

func _refresh_labels() -> void:
	var mid: Variant = SaveService.load_any_mid_game()
	var n: int = maxi(CampaignSession.campaign_level, 1)
	if mid != null:
		n = maxi(int(mid.get("level_number", n)), 1)
		_continue_btn.text = "Continue — Level %d" % n
	else:
		_continue_btn.text = "Continue — Level %d" % n
	_play_btn.text = "Play campaign"

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

func _start_level(level_number: int, resume: Variant) -> void:
	CampaignSession.request_play(maxi(level_number, 1), resume)
	get_tree().change_scene_to_file("res://ui/game_screen.tscn")
