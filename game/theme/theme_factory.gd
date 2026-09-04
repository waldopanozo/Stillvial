class_name ThemeFactory
extends RefCounted

const FONT_DISPLAY := preload("res://theme/fonts/display.ttf")
const FONT_UI := preload("res://theme/fonts/ui.ttf")

static func build() -> Theme:
	var t := Theme.new()
	_setup_fonts(t)
	_setup_buttons(t)
	_setup_check(t)
	_setup_labels(t)
	return t

static func _setup_fonts(t: Theme) -> void:
	t.set_default_font(FONT_UI)
	t.set_default_font_size(18)

static func _flat(bg: Color, border: Color, border_w: float, radius: float, expand_h: float = 10.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(int(border_w))
	s.set_corner_radius_all(int(radius))
	s.content_margin_left = 20.0
	s.content_margin_right = 20.0
	s.content_margin_top = expand_h
	s.content_margin_bottom = expand_h
	return s

static func _setup_buttons(t: Theme) -> void:
	var radius := 24.0
	# Secondary = default Button
	var sec_n := _flat(Color(0, 0, 0, 0), Palette.OUTLINE, 2.0, radius)
	var sec_h := _flat(Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.08), Palette.MIST, 2.0, radius)
	var sec_p := _flat(Color(Palette.TEAL.r, Palette.TEAL.g, Palette.TEAL.b, 0.2), Palette.TEAL, 2.0, radius)
	var sec_d := _flat(Color(0, 0, 0, 0), Color(Palette.OUTLINE.r, Palette.OUTLINE.g, Palette.OUTLINE.b, 0.3), 2.0, radius)
	t.set_stylebox("normal", "Button", sec_n)
	t.set_stylebox("hover", "Button", sec_h)
	t.set_stylebox("pressed", "Button", sec_p)
	t.set_stylebox("disabled", "Button", sec_d)
	t.set_stylebox("focus", "Button", sec_h)
	t.set_color("font_color", "Button", Palette.MIST)
	t.set_color("font_hover_color", "Button", Palette.MIST)
	t.set_color("font_pressed_color", "Button", Palette.MIST)
	t.set_color("font_disabled_color", "Button", Palette.MUTED_TEXT)
	t.set_font_size("font_size", "Button", 20)

	# Primary variation
	var pri_n := _flat(Palette.PRIMARY_FILL, Palette.PRIMARY_FILL, 0.0, radius)
	var pri_h := _flat(Palette.PRIMARY_FILL.lightened(0.08), Palette.PRIMARY_FILL, 0.0, radius)
	var pri_p := _flat(Palette.PRIMARY_FILL.darkened(0.08), Palette.PRIMARY_FILL, 0.0, radius)
	var pri_d := _flat(Palette.DISABLED_FILL, Palette.DISABLED_FILL, 0.0, radius)
	t.set_type_variation("Primary", "Button")
	t.set_stylebox("normal", "Primary", pri_n)
	t.set_stylebox("hover", "Primary", pri_h)
	t.set_stylebox("pressed", "Primary", pri_p)
	t.set_stylebox("disabled", "Primary", pri_d)
	t.set_stylebox("focus", "Primary", pri_h)
	t.set_color("font_color", "Primary", Palette.PRIMARY_TEXT)
	t.set_color("font_hover_color", "Primary", Palette.PRIMARY_TEXT)
	t.set_color("font_pressed_color", "Primary", Palette.PRIMARY_TEXT)
	t.set_color("font_disabled_color", "Primary", Color(Palette.PRIMARY_TEXT.r, Palette.PRIMARY_TEXT.g, Palette.PRIMARY_TEXT.b, 0.5))
	t.set_font_size("font_size", "Primary", 20)

	# Ghost variation — each state gets its own StyleBox instance
	var ghost_n := _flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0.0, radius, 8.0)
	var ghost_h := _flat(Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.06), Color(0, 0, 0, 0), 0.0, radius, 8.0)
	var ghost_p := _flat(Color(Palette.MIST.r, Palette.MIST.g, Palette.MIST.b, 0.06), Color(0, 0, 0, 0), 0.0, radius, 8.0)
	var ghost_d := _flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0.0, radius, 8.0)
	var ghost_f := _flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0.0, radius, 8.0)
	t.set_type_variation("Ghost", "Button")
	t.set_stylebox("normal", "Ghost", ghost_n)
	t.set_stylebox("hover", "Ghost", ghost_h)
	t.set_stylebox("pressed", "Ghost", ghost_p)
	t.set_stylebox("disabled", "Ghost", ghost_d)
	t.set_stylebox("focus", "Ghost", ghost_f)
	t.set_color("font_color", "Ghost", Palette.GHOST_TEXT)
	t.set_color("font_hover_color", "Ghost", Palette.MIST)
	t.set_color("font_pressed_color", "Ghost", Palette.TEAL)
	t.set_color("font_disabled_color", "Ghost", Palette.MUTED_TEXT)
	t.set_font_size("font_size", "Ghost", 16)

	t.set_type_variation("Secondary", "Button")
	# Secondary variation mirrors default Button styles
	t.set_stylebox("normal", "Secondary", sec_n)
	t.set_stylebox("hover", "Secondary", sec_h)
	t.set_stylebox("pressed", "Secondary", sec_p)
	t.set_stylebox("disabled", "Secondary", sec_d)
	t.set_stylebox("focus", "Secondary", sec_h)
	t.set_color("font_color", "Secondary", Palette.MIST)
	t.set_color("font_hover_color", "Secondary", Palette.MIST)
	t.set_color("font_pressed_color", "Secondary", Palette.MIST)
	t.set_color("font_disabled_color", "Secondary", Palette.MUTED_TEXT)
	t.set_font_size("font_size", "Secondary", 20)

static func _setup_check(t: Theme) -> void:
	# Transparent panels so CheckButton does not inherit Button secondary outline chrome.
	var empty := _flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0.0, 0.0, 4.0)
	t.set_stylebox("normal", "CheckButton", empty)
	t.set_stylebox("hover", "CheckButton", empty.duplicate())
	t.set_stylebox("pressed", "CheckButton", empty.duplicate())
	t.set_stylebox("disabled", "CheckButton", empty.duplicate())
	t.set_stylebox("focus", "CheckButton", empty.duplicate())
	t.set_color("font_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_color("font_hover_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_color("font_pressed_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_color("font_disabled_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_color("font_focus_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_color("icon_normal_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_color("icon_hover_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_color("icon_pressed_color", "CheckButton", Palette.TEAL)
	t.set_color("icon_disabled_color", "CheckButton", Palette.MUTED_TEXT)
	t.set_font_size("font_size", "CheckButton", 16)

static func _setup_labels(t: Theme) -> void:
	t.set_type_variation("Title", "Label")
	t.set_font("font", "Title", FONT_DISPLAY)
	t.set_font_size("font_size", "Title", 52)
	t.set_color("font_color", "Title", Palette.MIST)
	t.set_type_variation("Tagline", "Label")
	t.set_font("font", "Tagline", FONT_UI)
	t.set_font_size("font_size", "Tagline", 16)
	t.set_color("font_color", "Tagline", Palette.MUTED_TEXT)
