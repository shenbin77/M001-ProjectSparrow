extends Button

var tile_code: String = ""
var is_meld: bool = false
var is_riichi: bool = false
var is_last_draw: bool = false
var is_discard: bool = false

const SUIT_COLORS := {
	"m": Color(0.85, 0.22, 0.22),
	"p": Color(0.22, 0.45, 0.82),
	"s": Color(0.18, 0.62, 0.34),
	"z": Color(0.35, 0.35, 0.35)
}

const HONOR_NAMES := {
	"z1": "East", "z2": "South", "z3": "West", "z4": "North",
	"z5": "Haku", "z6": "Hatsu", "z7": "Chun"
}

const HONOR_ZH := {
	"z1": "东", "z2": "南", "z3": "西", "z4": "北",
	"z5": "白", "z6": "发", "z7": "中"
}

func setup(code: String, options: Dictionary = {}) -> void:
	tile_code = code
	is_meld = options.get("meld", false)
	is_riichi = options.get("riichi", false)
	is_last_draw = options.get("last_draw", false)
	is_discard = options.get("discard", false)
	custom_minimum_size = Vector2(44, 58) if not is_discard else Vector2(32, 42)
	tooltip_text = _tooltip()
	_update_visuals()
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_viewport().set_meta("tile_selected", tile_code)

func _tooltip() -> String:
	if HONOR_NAMES.has(tile_code):
		return "%s (%s)" % [tile_code, HONOR_NAMES[tile_code]]
	return tile_code

func _update_visuals() -> void:
	var suit := ""
	var num := ""
	for ch in tile_code:
		if ch in ["m", "p", "s", "z"]:
			suit = ch
		elif ch.is_valid_int():
			num = ch
	var display := ""
	if suit == "z" and HONOR_NAMES.has(tile_code):
		display = HONOR_ZH.get(tile_code, tile_code)
	else:
		display = num + _suit_label(suit)
	var bg := Color(0.95, 0.92, 0.86)
	if is_discard:
		bg = Color(0.75, 0.72, 0.66)
	elif is_riichi:
		bg = Color(0.85, 0.82, 0.76)
	elif is_last_draw:
		bg = Color(1.0, 0.97, 0.90)
	var fg: Color = SUIT_COLORS.get(suit, Color(0.25, 0.22, 0.20))
	if num == "0":
		fg = Color(0.9, 0.15, 0.15)
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = custom_minimum_size
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(0.6, 0.55, 0.50)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(2)
	if is_riichi:
		style.border_color = Color(0.9, 0.8, 0.2)
		style.set_border_width_all(2)
	if is_last_draw:
		style.border_color = Color(0.2, 0.7, 0.9)
		style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var lbl := Label.new()
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.text = display
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 18 if not is_discard else 14)
	lbl.add_theme_color_override("font_color", fg)
	panel.add_child(lbl)
	if is_meld:
		var meld_lbl := Label.new()
		meld_lbl.text = "M"
		meld_lbl.add_theme_font_size_override("font_size", 10)
		meld_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		meld_lbl.position = Vector2(2, 0)
		add_child(meld_lbl)

func _suit_label(suit: String) -> String:
	match suit:
		"m": return "m"
		"p": return "p"
		"s": return "s"
		_: return ""

static func from_raw(raw: String, options: Dictionary = {}) -> Button:
	var btn := new()
	btn.setup(raw, options)
	return btn
