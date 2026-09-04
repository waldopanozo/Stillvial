class_name CampaignSession
extends RefCounted

## In-memory campaign progress until SaveService (Task 6).

static var campaign_level: int = 1
static var max_completed: int = 0
## Level number GameScreen should load on enter.
static var requested_level: int = 1

static func request_play(level_number: int = -1) -> void:
	if level_number < 1:
		requested_level = maxi(campaign_level, 1)
	else:
		requested_level = level_number

static func register_win(level_number: int) -> void:
	max_completed = maxi(max_completed, level_number)
	if campaign_level <= level_number:
		campaign_level = level_number + 1
