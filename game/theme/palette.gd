class_name Palette
extends RefCounted

## Brand + extended water colors (ids 0..N). Background / glass helpers included.

const DEEP: Color = Color("12303A")
const MIST: Color = Color("E8F0E8")
const TEAL: Color = Color("3E9B8E")
const GOLD: Color = Color("D4B14B")
const SLATE: Color = Color("537B9C")

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

static func water(color_id: int) -> Color:
	if color_id < 0:
		return Color(0, 0, 0, 0)
	return WATER[color_id % WATER.size()]

static func glass_fill() -> Color:
	return Color(MIST.r, MIST.g, MIST.b, 0.22)

static func glass_stroke() -> Color:
	return Color(MIST.r, MIST.g, MIST.b, 0.55)

static func selection() -> Color:
	return Color(GOLD.r, GOLD.g, GOLD.b, 0.85)

static func board_bg() -> Color:
	return DEEP
