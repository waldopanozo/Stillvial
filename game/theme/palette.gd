class_name Palette
extends RefCounted

## Brand + extended water colors (ids 0..N). Each id maps to a pattern for a11y.

const DEEP: Color = Color("12303A")
const MIST: Color = Color("E8F0E8")
const TEAL: Color = Color("3E9B8E")
const GOLD: Color = Color("D4B14B")
const SLATE: Color = Color("537B9C")

enum Pattern {
	STRIPE,
	DOTS,
	WAVE,
	CROSS,
	HASH,
	CHEVRON,
	RINGS,
	DIAG,
}

## Distinct fills for campaign colors (LevelGenerator up to 16).
const WATER: Array[Color] = [
	TEAL, # 0
	GOLD, # 1
	SLATE, # 2
	Color("C45C6A"), # coral rose
	Color("6B8F3C"), # olive
	Color("8B6BB5"), # soft violet
	Color("D4783A"), # amber orange
	Color("3A8FA0"), # cyan teal
	Color("B85C8A"), # magenta
	Color("5C7A3A"), # moss
	Color("E0A050"), # sand
	Color("4A6FA5"), # denim
	Color("9B4E4E"), # brick
	Color("2E8B6E"), # sea green
	Color("A67C52"), # walnut
	Color("6E7A9B"), # dusk blue
]

## One pattern per color id (cycles if more ids than patterns).
const PATTERNS: Array[Pattern] = [
	Pattern.STRIPE, # 0
	Pattern.DOTS, # 1
	Pattern.WAVE, # 2
	Pattern.CROSS, # 3
	Pattern.HASH, # 4
	Pattern.CHEVRON, # 5
	Pattern.RINGS, # 6
	Pattern.DIAG, # 7
	Pattern.STRIPE, # 8 — alternate stroke density via ink only
	Pattern.DOTS, # 9
	Pattern.WAVE, # 10
	Pattern.CROSS, # 11
	Pattern.HASH, # 12
	Pattern.CHEVRON, # 13
	Pattern.RINGS, # 14
	Pattern.DIAG, # 15
]

static func water(color_id: int) -> Color:
	if color_id < 0:
		return Color(0, 0, 0, 0)
	return WATER[color_id % WATER.size()]

static func pattern(color_id: int) -> Pattern:
	if color_id < 0:
		return Pattern.STRIPE
	return PATTERNS[color_id % PATTERNS.size()]

## Contrasting ink for pattern marks (readable on small liquid bands).
static func pattern_ink(color_id: int) -> Color:
	var base: Color = water(color_id)
	var lum: float = base.r * 0.299 + base.g * 0.587 + base.b * 0.114
	if lum > 0.52:
		return Color(0.08, 0.1, 0.12, 0.55)
	return Color(1.0, 1.0, 1.0, 0.5)

## Draw fill + optional pattern. Call from CanvasItem._draw().
static func draw_liquid_band(ci: CanvasItem, band_size: Vector2, color_id: int, patterns_enabled: bool) -> void:
	if color_id < 0 or band_size.x <= 0.0 or band_size.y <= 0.0:
		return
	ci.draw_rect(Rect2(Vector2.ZERO, band_size), water(color_id))
	if not patterns_enabled:
		return
	_draw_pattern(ci, band_size, color_id)

static func _draw_pattern(ci: CanvasItem, band_size: Vector2, color_id: int) -> void:
	var ink: Color = pattern_ink(color_id)
	var w: float = band_size.x
	var h: float = band_size.y
	var pad: float = 3.0
	match pattern(color_id):
		Pattern.STRIPE:
			var step: float = maxf(6.0, w * 0.22)
			var x: float = pad
			while x < w - pad:
				ci.draw_line(Vector2(x, pad), Vector2(x, h - pad), ink, 2.0)
				x += step
		Pattern.DOTS:
			var cols: int = 3 if w >= 28.0 else 2
			var rows: int = 2 if h >= 18.0 else 1
			var r: float = mini(2.4, mini(w, h) * 0.12)
			for row in rows:
				for col in cols:
					var cx: float = pad + (w - pad * 2.0) * (float(col) + 0.5) / float(cols)
					var cy: float = pad + (h - pad * 2.0) * (float(row) + 0.5) / float(rows)
					ci.draw_circle(Vector2(cx, cy), r, ink)
		Pattern.WAVE:
			var mid_y: float = h * 0.5
			var amp: float = mini(h * 0.28, 5.0)
			var pts: PackedVector2Array = PackedVector2Array()
			var x: float = pad
			while x <= w - pad:
				var t: float = (x - pad) / maxf(w - pad * 2.0, 1.0)
				pts.append(Vector2(x, mid_y + sin(t * TAU * 1.5) * amp))
				x += 3.0
			if pts.size() >= 2:
				ci.draw_polyline(pts, ink, 2.0, true)
		Pattern.CROSS:
			var m: Vector2 = band_size * 0.5
			var arm: float = mini(w, h) * 0.32
			ci.draw_line(m + Vector2(-arm, -arm), m + Vector2(arm, arm), ink, 2.2)
			ci.draw_line(m + Vector2(-arm, arm), m + Vector2(arm, -arm), ink, 2.2)
		Pattern.HASH:
			var step_x: float = maxf(7.0, w * 0.28)
			var step_y: float = maxf(7.0, h * 0.35)
			var x: float = pad + 2.0
			while x < w - pad:
				ci.draw_line(Vector2(x, pad), Vector2(x, h - pad), ink, 1.6)
				x += step_x
			var y: float = pad + 2.0
			while y < h - pad:
				ci.draw_line(Vector2(pad, y), Vector2(w - pad, y), ink, 1.6)
				y += step_y
		Pattern.CHEVRON:
			var mid_x: float = w * 0.5
			var step: float = maxf(6.0, h * 0.35)
			var y: float = pad + 2.0
			while y < h - pad:
				ci.draw_line(Vector2(pad + 1.0, y + 3.0), Vector2(mid_x, y - 1.0), ink, 2.0)
				ci.draw_line(Vector2(mid_x, y - 1.0), Vector2(w - pad - 1.0, y + 3.0), ink, 2.0)
				y += step
		Pattern.RINGS:
			var cx: float = w * 0.5
			var cy: float = h * 0.5
			var r0: float = mini(w, h) * 0.18
			var r1: float = mini(w, h) * 0.34
			ci.draw_arc(Vector2(cx, cy), r0, 0.0, TAU, 16, ink, 1.8, true)
			if r1 > r0 + 2.0:
				ci.draw_arc(Vector2(cx, cy), r1, 0.0, TAU, 20, ink, 1.6, true)
		Pattern.DIAG:
			var step: float = maxf(7.0, w * 0.25)
			var x: float = -h + pad
			while x < w + h:
				ci.draw_line(Vector2(x, pad), Vector2(x + h - pad * 2.0, h - pad), ink, 1.8)
				x += step

static func glass_fill() -> Color:
	return Color(MIST.r, MIST.g, MIST.b, 0.28)

static func glass_stroke() -> Color:
	return Color(MIST.r, MIST.g, MIST.b, 0.7)

static func selection() -> Color:
	return Color(GOLD.r, GOLD.g, GOLD.b, 0.85)

static func tip_highlight() -> Color:
	return Color(TEAL.r, TEAL.g, TEAL.b, 0.9)

static func board_bg() -> Color:
	return DEEP

## UI surfaces (Home / future HUD)
const SURFACE: Color = Color("0F2A32")
const SURFACE_RAISED: Color = Color("1A3A44")
const PRIMARY_FILL: Color = TEAL
const PRIMARY_TEXT: Color = Color("0A1A1E")
const OUTLINE: Color = Color(MIST.r, MIST.g, MIST.b, 0.55)
const GHOST_TEXT: Color = Color(MIST.r, MIST.g, MIST.b, 0.85)
const MUTED_TEXT: Color = Color(MIST.r, MIST.g, MIST.b, 0.7)
const DISABLED_FILL: Color = Color(TEAL.r, TEAL.g, TEAL.b, 0.35)
