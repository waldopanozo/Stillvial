extends Control
## Soft deep→teal gradient for the play board (no decorative vial).

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	# Vertical gradient via stacked rects (cheap, no shader required)
	var steps := 24
	for i in steps:
		var t := float(i) / float(steps - 1)
		var c := Palette.DEEP.lerp(
			Color(Palette.TEAL.r * 0.25, Palette.TEAL.g * 0.35, Palette.TEAL.b * 0.38),
			t * 0.85
		)
		var y0 := r.size.y * float(i) / float(steps)
		var y1 := r.size.y * float(i + 1) / float(steps)
		draw_rect(Rect2(0.0, y0, r.size.x, y1 - y0 + 1.0), c)
	# Soft vignette (top / bottom bands)
	draw_rect(Rect2(0, 0, r.size.x, r.size.y * 0.08), Color(0, 0, 0, 0.12))
	draw_rect(Rect2(0, r.size.y * 0.92, r.size.x, r.size.y * 0.08), Color(0, 0, 0, 0.18))
