extends Control
## Soft deep→teal gradient and a large decorative vial silhouette.

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
	_draw_vial(r.size)


func _draw_vial(sz: Vector2) -> void:
	var cx := sz.x * 0.5
	var top := sz.y * 0.12
	var body_h := sz.y * 0.42
	var neck_w := mini(36.0, sz.x * 0.06)
	var body_w := mini(120.0, sz.x * 0.22)
	var ink := Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.14)
	var neck_h := body_h * 0.18
	var body_top := top + body_h * 0.16
	var body_h_rect := body_h * 0.72
	var left := cx - body_w * 0.5
	var right := cx + body_w * 0.5
	var n_l := cx - neck_w * 0.5
	var n_r := cx + neck_w * 0.5
	var body_bottom := body_top + body_h_rect
	var radius := body_w * 0.5

	# Continuous bottle outline: lip → neck → shoulder → body → bottom arc → back up
	var pts := PackedVector2Array()
	pts.append(Vector2(n_l, top))
	pts.append(Vector2(n_r, top))
	pts.append(Vector2(n_r, top + neck_h))
	pts.append(Vector2(right, body_top))
	pts.append(Vector2(right, body_bottom))
	# Bottom semicircle right → left (angles 0 → PI)
	var arc_steps := 24
	for i in range(1, arc_steps):
		var a := float(i) / float(arc_steps) * PI
		pts.append(Vector2(cx + cos(a) * radius, body_bottom + sin(a) * radius))
	pts.append(Vector2(left, body_bottom))
	pts.append(Vector2(left, body_top))
	pts.append(Vector2(n_l, top + neck_h))
	pts.append(Vector2(n_l, top))
	draw_polyline(pts, ink, 2.5, true)
