class_name CampaignSession
extends RefCounted

## Campaign / daily session bridge (hydrated from SaveService on home).

enum PlayMode { CAMPAIGN, DAILY }

static var campaign_level: int = 1
static var max_completed: int = 0
## Level number GameScreen should load on enter (campaign only).
static var requested_level: int = 1
## Mid-game resume payload for GameScreen, or null.
static var resume_payload: Variant = null
static var play_mode: int = PlayMode.CAMPAIGN
## UTC `YYYYMMDD` when play_mode == DAILY.
static var daily_date_key: String = ""

static func apply_progress(current_level: int, completed: int) -> void:
	campaign_level = maxi(current_level, 1)
	max_completed = maxi(completed, 0)

static func request_play(level_number: int = -1, resume: Variant = null) -> void:
	play_mode = PlayMode.CAMPAIGN
	daily_date_key = ""
	resume_payload = resume
	if level_number < 1:
		requested_level = maxi(campaign_level, 1)
	else:
		requested_level = level_number

static func request_daily(date_key: String) -> void:
	play_mode = PlayMode.DAILY
	daily_date_key = date_key.strip_edges()
	requested_level = 0
	resume_payload = null

static func is_daily() -> bool:
	return play_mode == PlayMode.DAILY

static func register_win(level_number: int) -> void:
	max_completed = maxi(max_completed, level_number)
	if campaign_level <= level_number:
		campaign_level = level_number + 1
	resume_payload = null
