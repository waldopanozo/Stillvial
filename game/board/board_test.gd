extends Control

## Manual board smoke: loads LevelGenerator.generate(1).

@onready var _board: BoardView = $BoardView
@onready var _label: Label = $Hud/Label

func _ready() -> void:
	var level: Level = LevelGenerator.generate(1)
	_board.load_level(level)
	_board.pour_finished.connect(_on_pour)
	_board.level_completed.connect(_on_complete)
	_refresh_hud()

func _on_pour(_from: int, _to: int, _amount: int) -> void:
	_refresh_hud()

func _on_complete() -> void:
	_label.text = "Complete — moves %d" % _board.get_level().move_count

func _refresh_hud() -> void:
	var level: Level = _board.get_level()
	if level == null:
		return
	_label.text = "Level %d · moves %d · colors %d" % [
		level.level_number, level.move_count, level.color_count()
	]
