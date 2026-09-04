class_name PourAnimator
extends Node

## Tweens a pour ghost, then invokes on_done. Domain is applied by the caller.

const POUR_DURATION := 0.38

var low_effects: bool = false
## Parent for pour ghosts (must not be a container that auto-layouts children).
var overlay: Control

func animate_pour(
	from_view: TubeView,
	to_view: TubeView,
	color_id: int,
	amount: int,
	to_tube: Tube,
	on_done: Callable
) -> void:
	if amount <= 0:
		on_done.call()
		return

	var host: Control = overlay
	if host == null:
		host = from_view

	# Capture source rect before hiding poured units.
	var top_one: Rect2 = from_view.top_segment_global_rect()
	var unit_h: float = top_one.size.y
	var start := Rect2(
		top_one.position - Vector2(0, unit_h * float(amount - 1)),
		Vector2(top_one.size.x, unit_h * float(amount))
	)

	var end: Rect2 = to_view.next_empty_global_rect(to_tube)
	end.size.y = unit_h * float(amount)
	end.position.y -= unit_h * float(amount - 1)

	from_view.hide_top_units(amount)

	var ghost := ColorRect.new()
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.color = Palette.water(color_id)
	ghost.z_index = 20
	host.add_child(ghost)
	ghost.global_position = start.position
	ghost.size = start.size

	var peak_y: float = mini(start.position.y, end.position.y) - 48.0
	var mid := Vector2(
		(start.position.x + end.position.x) * 0.5,
		peak_y
	)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(ghost, "global_position", mid, POUR_DURATION * 0.45)
	tween.parallel().tween_property(ghost, "size", Vector2(start.size.x * 0.7, start.size.y), POUR_DURATION * 0.45)
	tween.tween_property(ghost, "global_position", end.position, POUR_DURATION * 0.55)
	tween.parallel().tween_property(ghost, "size", end.size, POUR_DURATION * 0.55)
	tween.tween_callback(func() -> void:
		ghost.queue_free()
		_spawn_splash(to_view, color_id)
		on_done.call()
	)

func _spawn_splash(at_view: TubeView, color_id: int) -> void:
	if low_effects:
		return
	# Optional MVP particles: brief flash only (no GPUParticles required).
	var host: Control = overlay
	if host == null:
		return
	var flash := ColorRect.new()
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.color = Color(Palette.water(color_id), 0.45)
	flash.z_index = 21
	host.add_child(flash)
	var r: Rect2 = at_view.get_global_rect()
	flash.global_position = Vector2(r.position.x + 8.0, r.position.y + 24.0)
	flash.size = Vector2(r.size.x - 16.0, 12.0)
	var tw := create_tween()
	tw.tween_property(flash, "modulate:a", 0.0, 0.22)
	tw.tween_callback(flash.queue_free)
