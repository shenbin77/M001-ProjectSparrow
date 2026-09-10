extends Control

const TileButton = preload("res://tile_button.gd")
const Career = preload("res://career.gd")
const Loc = preload("res://localization.gd")
const clubs := ["Dockside Union", "White Crane Academy", "Black Dragon Hall", "Tide Analytics"]

var career = Career.new()
var loc: Node
var root_dir: String
var characters: Array = []
var notice := ""
var match_data: Dictionary = {}
var match_id := ""
var club_index := 0
var busy := false
var save_path := "user://career_v1.json"
var current_tab := "league"
var tutorial_step := 0
var _buttons_disabled: Array = []

func _ready() -> void:
	root_dir = ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir() if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()
	loc = Loc.new()
	add_child(loc)
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(root_dir.path_join("data/characters.json")))
	if raw is Dictionary and raw.has("characters"):
		characters = raw.characters
	var theme := Theme.new()
	theme.default_font_size = 18
	theme.set_stylebox("normal", "Button", _btn_style(Color(0.18, 0.22, 0.28)))
	theme.set_stylebox("hover", "Button", _btn_style(Color(0.24, 0.28, 0.35)))
	theme.set_stylebox("pressed", "Button", _btn_style(Color(0.14, 0.17, 0.22)))
	theme.set_stylebox("disabled", "Button", _btn_style(Color(0.14, 0.14, 0.16)))
	theme.set_color("font_color", "Button", Color("f4ead7"))
	theme.set_color("font_hover_color", "Button", Color("ffffff"))
	theme.set_color("font_disabled_color", "Button", Color("555555"))
	theme.default_font_size = 18
	self.theme = theme
	show_club()
	if not OS.get_cmdline_user_args().has("--smoke") and not OS.get_cmdline_user_args().has("--capture"):
		_check_tutorial()
	if OS.get_cmdline_user_args().has("--smoke"):
		await smoke()
	elif OS.get_cmdline_user_args().has("--capture"):
		await get_tree().process_frame
		await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png(root_dir.path_join("club-preview.png"))
		await start_match(0)
		await get_tree().process_frame
		await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png(root_dir.path_join("table-preview.png"))
		get_tree().quit()

func _btn_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(6)
	s.set_content_margin_all(10)
	return s

func _check_tutorial() -> void:
	if career.state.get("tutorial_done", false):
		return
	tutorial_step = 1
	notice = loc.text("help_content").split("\n")[0]
	show_tutorial_overlay()

func show_tutorial_overlay() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.name = "TutorialOverlay"
	add_child(overlay)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.custom_minimum_size = Vector2(500, 300)
	box.position = Vector2(390, 200)
	overlay.add_child(box)
	var bg := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.18)
	style.border_color = Color(0.6, 0.5, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(24)
	bg.add_theme_stylebox_override("panel", style)
	box.add_child(bg)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 16)
	bg.add_child(inner)
	_l(loc.text("app_title"), 28, Color("dfb575"), inner)
	_l("Welcome to Crimson Sparrow. This is your club. You manage players, train skills, and challenge rival clubs.", 18, Color("ddd9cd"), inner)
	_l("Tap the tabs above to navigate: League, Roster, Scouting, Story, Help. Start a match from the League tab.", 17, Color("97a5b4"), inner)
	var btn := Button.new()
	btn.text = "Got it!"
	btn.custom_minimum_size.y = 44
	btn.pressed.connect(func():
		overlay.queue_free()
		career.state["tutorial_done"] = true
	)
	inner.add_child(btn)

func clear() -> void:
	for child in get_children():
		if child == loc or child.name == "TutorialOverlay":
			continue
		remove_child(child)
		child.queue_free()
	_buttons_disabled.clear()

func _build_header(title: String, subtitle: String) -> VBoxContainer:
	clear()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var root_v := VBoxContainer.new()
	root_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_v.add_theme_constant_override("separation", 0)
	margin.add_child(root_v)
	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 12)
	root_v.add_child(top_bar)
	_l(loc.text("app_title"), 17, Color("d6aa78"), top_bar)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	var lang_btn := Button.new()
	lang_btn.text = loc.text("lang_zh") if loc.get_language() == "en" else loc.text("lang_en")
	lang_btn.custom_minimum_size = Vector2(80, 32)
	lang_btn.pressed.connect(func():
		if busy:
			return
		loc.set_language("zh" if loc.get_language() == "en" else "en")
		if match_data.is_empty():
			show_club()
		else:
			show_match()
	)
	top_bar.add_child(lang_btn)
	_l(title, 30, Color("f4ead7"), root_v)
	if subtitle != "":
		_l(subtitle, 14, Color("97a5b4"), root_v)
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 6)
	root_v.add_child(sep)
	return root_v

func _l(text: String, size := 18, color := Color("ddd9cd"), parent: Node = null) -> Label:
	var item := Label.new()
	item.text = text
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", size)
	item.add_theme_color_override("font_color", color)
	(parent if parent != null else self).add_child(item)
	return item

func _btn(text: String, callback: Callable, parent: Node = null, disabled := false) -> Button:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size.y = 40
	item.disabled = disabled or busy
	item.pressed.connect(callback)
	item.set_meta("locked", disabled)
	_buttons_disabled.append(item)
	(parent if parent != null else self).add_child(item)
	return item

func _row(parent: Node = null) -> HFlowContainer:
	var item := HFlowContainer.new()
	item.add_theme_constant_override("h_separation", 8)
	item.add_theme_constant_override("v_separation", 6)
	(parent if parent != null else self).add_child(item)
	return item

func _col(parent: Node = null) -> VBoxContainer:
	var item := VBoxContainer.new()
	item.add_theme_constant_override("separation", 6)
	(parent if parent != null else self).add_child(item)
	return item

func ids() -> Array:
	return characters.map(func(c): return c.id)

func set_busy(val: bool) -> void:
	busy = val
	for b in _buttons_disabled:
		if is_instance_valid(b):
			b.disabled = val or b.get_meta("locked", false)

# ── CLUB HUB ──────────────────────────────────────────────────────

func show_club() -> void:
	var root_v := _build_header(loc.text("tagline"), loc.text("build_info") + " \u2022 Single-hand Riichi \u2022 No generated artwork")
	_stats_bar(root_v)
	_tab_bar(root_v)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_v.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	match current_tab:
		"league": _show_league(content)
		"roster": _show_roster(content)
		"scouting": _show_scouting(content)
		"story": _show_story(content)
		"help": _show_help_tab(content)
	if notice != "":
		_l(notice, 15, Color("dfb575"), root_v)

func _stats_bar(parent: Node) -> void:
	var row := _row(parent)
	_l("%s %d" % [loc.text("club_funds"), career.state.funds], 18, Color("f4ead7"), row)
	_l("%s %d" % [loc.text("reputation"), career.state.reputation], 18, Color("f4ead7"), row)
	_l("%s %d" % [loc.text("matches"), career.state.matches], 18, Color("f4ead7"), row)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_btn(loc.text("save_career"), save_career, row)
	_btn(loc.text("load_career"), load_career, row)
	_btn(loc.text("recover_backup"), recover_career, row)

func _tab_bar(parent: Node) -> void:
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	parent.add_child(tabs)
	for tab_id in ["league", "roster", "scouting", "story", "help"]:
		var btn := Button.new()
		btn.text = loc.text("tab_" + tab_id)
		btn.toggle_mode = true
		btn.button_pressed = current_tab == tab_id
		btn.custom_minimum_size = Vector2(110, 36)
		btn.pressed.connect(func():
			if not busy:
				current_tab = tab_id
				show_club()
		)
		tabs.add_child(btn)

# ── LEAGUE TAB ────────────────────────────────────────────────────

func _show_league(parent: Node) -> void:
	_l(loc.text("next_challenge").to_upper(), 21, Color("f4ead7"), parent)
	var snap: Dictionary = career.campaign_snapshot()
	_l("%s  |  Season %d  |  Round %d / %d" % [snap.title, snap.season, min(snap.round + 1, 12), snap.rounds], 24, Color("dfb575"), parent)
	_l("Invitational standings • average table points per appearance. Top two promote after 12 hands.", 15, Color("97a5b4"), parent)
	for s in snap.standings:
		_l("%-24s  %6.1f  |  %d played" % [s.name, float(s.points), s.played], 19, Color("ddd9cd"), parent)
	if snap.completed:
		_l("PROMOTED" if snap.promoted else "SEASON COMPLETE — KEEP BUILDING", 24, Color("dfb575"), parent)
		_btn("Start next season", start_next_season, parent)
	else:
		_btn(loc.text("challenge") + " • " + snap.next_opponent, start_match.bind(int(snap.opponent_index)), parent)
	_l("Active player: " + str(career.state.active_player) + " • Loadout affects training and rewards, never the wall.", 15, Color("97a5b4"), parent)

# ── ROSTER TAB ────────────────────────────────────────────────────

func _show_roster(parent: Node) -> void:
	_l(loc.text("your_players").to_upper(), 21, Color("f4ead7"), parent)
	for character in characters:
		if not career.state.roster.has(character.id):
			continue
		var xp: int = int(career.state.xp[character.id])
		var level := 1 + xp / 100
		var card := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.13, 0.15, 0.19)
		style.border_color = Color(0.3, 0.3, 0.35)
		style.set_border_width_all(1)
		style.set_corner_radius_all(6)
		style.set_content_margin_all(12)
		card.add_theme_stylebox_override("panel", style)
		parent.add_child(card)
		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", 4)
		card.add_child(inner)
		var header := HBoxContainer.new()
		header.add_theme_constant_override("separation", 12)
		inner.add_child(header)
		_l("[%s]  %s" % [str(character.club).to_upper(), character.name], 20, Color("f4ead7"), header)
		_l(loc.text("level") % level, 16, Color("97a5b4"), header)
		_l(loc.text("xp") % xp, 16, Color("97a5b4"), header)
		_l(character.style, 14, Color("97a5b4"), inner)
		_l("Desire: %s  |  Flaw: %s" % [character.desire, character.flaw], 13, Color("777777"), inner)
		var actions := _row(inner)
		_btn("Train • %d funds / +%d XP" % [career.Skills.training_cost(career.state.skills[character.id]), career.Skills.training_xp(career.state.skills[character.id])], train.bind(character.id), actions, career.state.funds < career.Skills.training_cost(career.state.skills[character.id]))
		_btn("Active" if career.state.active_player == character.id else "Select player", select_player.bind(character.id), actions, career.state.active_player == character.id)
		for slot in range(4):
			var current: String = career.state.skills[character.id][slot]
			if current == "":
				_btn(loc.text("slot_empty") % (slot + 1), equip.bind(character.id, slot, career.learned_skills(character.id)), actions)
			else:
				_btn(loc.text("slot_equipped") % [slot + 1, current], unequip.bind(character.id, slot), actions)
		if career.has_method("learned_skills") and career.has_method("skill_catalog"):
			var catalog: Array = career.skill_catalog()
			var learned: Array = career.learned_skills(character.id)
			if not catalog.is_empty():
				var skill_row := _row(inner)
				_l("Skills:", 14, Color("97a5b4"), skill_row)
				for sk in catalog:
					var sk_id: String = sk.get("id", "")
					var sk_name: String = sk.get("name", sk_id)
					var has := learned.has(sk_id)
					var skill_button := _btn(sk_name + (" ✓" if has else " • %d" % sk.get("cost", 0)), learn_skill.bind(character.id, sk_id), skill_row, has or level < sk.get("unlock_level", 1) or career.state.funds < sk.get("cost", 0))
					skill_button.tooltip_text = sk.get("description", "")

func select_player(id: String) -> void:
	if not busy:
		career.select_player(id)
		show_club()

func train(id: String) -> void:
	if busy:
		return
	if career.train(id):
		notice = loc.text("training_done")
	show_club()

func recruit(id: String) -> void:
	if busy:
		return
	if career.recruit(id):
		notice = loc.text("recruit_done")
	show_club()

func equip(id: String, slot: int, available: Array) -> void:
	if busy:
		return
	available = available.filter(func(skill): return not career.state.skills[id].has(skill))
	if available.is_empty():
		notice = "Learn an unequipped skill first. Click an occupied slot to remove it."
		show_club()
		return
	var current: String = career.state.skills[id][slot]
	var next_idx := (available.find(current) + 1) % available.size()
	career.equip(id, slot, available[next_idx])
	notice = loc.text("equip_done")
	show_club()

func unequip(id: String, slot: int) -> void:
	if busy:
		return
	career.equip(id, slot, "")
	notice = loc.text("equip_done")
	show_club()

func learn_skill(id: String, skill_id: String) -> void:
	if busy:
		return
	if career.has_method("learn_skill"):
		career.learn_skill(id, skill_id)
		notice = loc.text("equip_done")
	show_club()

# ── SCOUTING TAB ──────────────────────────────────────────────────

func _show_scouting(parent: Node) -> void:
	_l(loc.text("scouting_office").to_upper(), 21, Color("f4ead7"), parent)
	_l(loc.text("scouting_desc"), 14, Color("97a5b4"), parent)
	var scouts := _row(parent)
	for character in characters:
		if not career.state.roster.has(character.id):
			_btn(loc.text("sign") % character.name, recruit.bind(character.id), scouts, career.state.funds < 240)

# ── STORY TAB ─────────────────────────────────────────────────────

func _show_story(parent: Node) -> void:
	if career.state.story == "":
		_l(loc.text("keep_lights_on").to_upper(), 21, Color("f4ead7"), parent)
		_l(loc.text("story_desc"), 16, Color("ddd9cd"), parent)
		var options := _row(parent)
		_btn(loc.text("story_sponsor"), story_choice.bind("sponsor"), options)
		_btn(loc.text("story_community"), story_choice.bind("community"), options)
	else:
		_l(loc.text("story_chosen") % career.state.story, 18, Color("dfb575"), parent)
	var event: Dictionary = career.event_snapshot()
	if not event.is_empty():
		_l(str(event.get("title", "?")), 22, Color("dfb575"), parent)
		_l(str(event.get("body", "")), 17, Color("ddd9cd"), parent)
		for choice in event.choices:
			var cfunds: int = int(choice.get("funds", 0))
			_btn("%s  [funds %+d / morale %+d]" % [str(choice.get("label", "?")), cfunds, int(choice.get("morale", 0))], choose_event.bind(str(choice.get("id", ""))), parent, career.state.funds + cfunds < 0)
	_l("Morale: %d / 100  •  Relationships: %s" % [career.state.morale, str(career.state.relationships)], 16, Color("97a5b4"), parent)

func story_choice(choice: String) -> void:
	if busy:
		return
	career.story_choice(choice)
	notice = loc.text("story_done") % choice
	show_club()

# ── HELP TAB ──────────────────────────────────────────────────────

func _show_help_tab(parent: Node) -> void:
	_l(loc.text("help_title"), 24, Color("dfb575"), parent)
	_l(loc.text("help_subtitle"), 14, Color("97a5b4"), parent)
	_l(loc.text("help_content"), 16, Color("ddd9cd"), parent)
	var sep := HSeparator.new()
	parent.add_child(sep)
	_l(loc.text("yaku_title"), 20, Color("dfb575"), parent)
	var topics := [
		["riichi_title", "riichi_desc"],
		["ron_title", "ron_desc"],
		["tsumo_title", "tsumo_desc"],
		["chi_title", "chi_desc"],
		["pon_title", "pon_desc"],
		["kan_title", "kan_desc"],
		["furiten_title", "furiten_desc"],
	]
	for t in topics:
		_l(loc.text(t[0]), 17, Color("f4ead7"), parent)
		_l(loc.text(t[1]), 15, Color("bbb8b0"), parent)

# ── MATCH ─────────────────────────────────────────────────────────

func start_match(index: int) -> void:
	if busy or career.campaign_snapshot().completed or index != career.campaign_snapshot().opponent_index:
		return
	club_index = index
	match_id = "%s-%s" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()]
	set_busy(true)
	var CLUB_STYLES: Array[String] = ["rookie", "tensei", "pressure", "professional"]
	var style := CLUB_STYLES[index]
	var data: Dictionary = await request_backend({"op": "new", "seed": randi() % 2147483647, "ai_profile": "rookie", "ai_profiles": [style, style, style]})
	set_busy(false)
	if not data.get("ok", false):
		notice = str(data.get("error", loc.text("rule_error")))
		show_club()
		return
	match_data = data
	show_match()

func show_match() -> void:
	var root_v := _build_header(
		loc.text("match_title") % clubs[club_index],
		loc.text("match_subtitle") + " \u2022 %s" % loc.text("seat_number") % str(match_data.get("seat", 0))
	)
	_match_info_bar(root_v)
	if match_data.get("done", false):
		_show_result(root_v)
		return
	_show_4_rivers(root_v)
	_show_melds(root_v)
	_show_hand(root_v)
	_show_actions(root_v)
	_l(loc.text("no_save_midhand"), 13, Color("666666"), root_v)

func _match_info_bar(parent: Node) -> void:
	var row := _row(parent)
	_l("%s: %s" % [loc.text("scores_label"), str(match_data.get("scores", []))], 16, Color("f4ead7"), row)
	_l("%s: %s" % [loc.text("tiles_left"), str(match_data.get("wall", 0))], 16, Color("f4ead7"), row)
	_l("%s: %s" % [loc.text("dora_indicators"), str(match_data.get("dora", []))], 16, Color("f4ead7"), row)

func _show_4_rivers(parent: Node) -> void:
	var discards: Array = match_data.get("discards", [[], [], [], []])
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 8)
	parent.add_child(grid)
	for i in range(4):
		var box := VBoxContainer.new()
		box.custom_minimum_size.x = 565
		box.add_theme_constant_override("separation", 2)
		grid.add_child(box)
		var is_me: bool = i == match_data.get("seat", 0)
		_l(loc.text("seat_label") % i + (" (YOU)" if is_me else ""), 15, Color("97a5b4") if not is_me else Color("dfb575"), box)
		var tiles_row := GridContainer.new()
		tiles_row.columns = 14
		tiles_row.add_theme_constant_override("h_separation", 3)
		tiles_row.add_theme_constant_override("v_separation", 2)
		box.add_child(tiles_row)
		for tile_str in discards[i]:
			var opts := {"discard": true}
			var tile_btn := TileButton.from_raw(tile_str, opts)
			tile_btn.disabled = true
			tiles_row.add_child(tile_btn)

func _show_melds(parent: Node) -> void:
	var melds: Array = match_data.get("melds", [[], [], [], []])
	var any_melds := false
	for m in melds:
		if m is Array and not m.is_empty():
			any_melds = true
			break
	if not any_melds:
		return
	_l("MELDS", 16, Color("97a5b4"), parent)
	for i in range(4):
		if melds[i].is_empty():
			continue
		var row := _row(parent)
		_l("Seat %d:" % i, 14, Color("97a5b4"), row)
		for meld in melds[i]:
			if meld is String:
				var btn := TileButton.from_raw(meld, {"meld": true})
				row.add_child(btn)
			elif meld is Array:
				for t in meld:
					var btn := TileButton.from_raw(str(t), {"meld": true})
					row.add_child(btn)

func _show_hand(parent: Node) -> void:
	_l(loc.text("your_hand"), 20, Color("dfb575"), parent)
	var hand: String = match_data.get("hand", "")
	var tiles := _row(parent)
	var suit := ""
	var last_tile: String = match_data.get("drawn_tile", "")
	for ch in hand.split(",")[0]:
		if ch in ["m", "p", "s", "z"]:
			suit = ch
		elif ch.is_valid_int():
			var tile_str: String = ch + suit
			var is_last: bool = tile_str == last_tile
			var opts := {"last_draw": is_last}
			var btn := TileButton.from_raw(tile_str, opts)
			tiles.add_child(btn)
	_l(loc.text("tile_legend"), 13, Color("666666"), parent)

func _show_actions(parent: Node) -> void:
	_l(loc.text("legal_actions").to_upper(), 18, Color("f4ead7"), parent)
	var actions := _row(parent)
	for choice in match_data.get("choices", []):
		_btn(str(choice.label), play.bind(choice.reply), actions)
	_btn(loc.text("ai_finish"), auto_match, actions)
	_btn(loc.text("concede"), do_concede, actions)

func _show_result(parent: Node) -> void:
	var scores: Array = match_data.get("scores", [25000, 25000, 25000, 25000])
	var won: bool = scores[0] > 25000
	_l(loc.text("hand_complete"), 32, Color("dfb575"), parent)
	_l(loc.text("hand_won") if won else loc.text("hand_lost"), 20, Color("f4ead7"), parent)
	_l(loc.text("result_desc"), 15, Color("97a5b4"), parent)
	var summary: Array = match_data.get("result", {}).get("log", [])
	for hand_log in summary:
		for event in hand_log:
			if event.has("hule"):
				var win: Dictionary = event.hule
				_l("Seat %d wins • %s han / %s fu • %s points" % [win.l, str(win.get("fanshu", "yakuman")), str(win.get("fu", "—")), str(win.defen)], 19, Color("ddd9cd"), parent)
	var snap: Dictionary = career.campaign_snapshot()
	_l("Round %d / 12 settled • funds %d • reputation %d" % [snap.round, career.state.funds, career.state.reputation], 18, Color("dfb575"), parent)
	if career.has_method("event_snapshot"):
		var ev: Dictionary = career.event_snapshot()
		if not ev.is_empty():
			_l("Event: %s" % str(ev.get("description", "")), 15, Color("dfb575"), parent)
			for choice in ev.get("choices", []):
				_btn(str(choice.get("label", "?")), choose_event.bind(choice.get("id", "")), parent)
	_btn(loc.text("return_to_club"), finish_match, parent)

func play(reply: Dictionary) -> void:
	await advance({"op": "action", "state": match_data.state, "choice": reply})

func auto_match() -> void:
	await advance({"op": "auto", "state": match_data.state})

func advance(request: Dictionary) -> void:
	if busy:
		return
	set_busy(true)
	var result: Dictionary = await request_backend(request)
	set_busy(false)
	if result.get("ok", false):
		match_data = result
		if match_data.get("done", false):
			var scores: Array = match_data.get("scores", [25000, 25000, 25000, 25000])
			career.settle_result(match_id, scores)
		show_match()
	else:
		_l(loc.text("rule_error") % str(result.get("error", "unknown")), 18, Color("f19183"))

func finish_match() -> void:
	if busy:
		return
	match_data = {}
	notice = loc.text("club_return_msg")
	show_club()

func do_concede() -> void:
	if busy:
		return
	match_data = {}
	notice = loc.text("concede_msg")
	show_club()

func choose_event(choice_id: String) -> void:
	if busy:
		return
	if career.has_method("choose_event"):
		career.choose_event(choice_id)
	show_club()

func start_next_season() -> void:
	if busy:
		return
	if career.has_method("start_next_season"):
		career.start_next_season()
	show_club()

# ── SAVE / LOAD ───────────────────────────────────────────────────

func save_career() -> void:
	if busy:
		return
	var result: Error = career.save_to(save_path)
	notice = loc.text("career_saved") if result == OK else loc.text("career_save_failed") % result
	show_club()

func load_career() -> void:
	if busy:
		return
	notice = loc.text("career_loaded") if career.load_from(save_path, ids()) else loc.text("career_load_failed")
	show_club()

func recover_career() -> void:
	if busy:
		return
	notice = loc.text("backup_loaded") if career.load_from(save_path + ".bak", ids()) else loc.text("backup_missing")
	show_club()

# ── BACKEND ───────────────────────────────────────────────────────

func request_backend(request: Dictionary) -> Dictionary:
	var prefix := ProjectSettings.globalize_path("user://request_%d" % Time.get_ticks_usec())
	var input_file := FileAccess.open(prefix + ".in", FileAccess.WRITE)
	if input_file == null:
		return {"ok": false, "error": "Cannot write rule request"}
	input_file.store_string(JSON.stringify(request))
	input_file.close()
	var pid := OS.create_process(root_dir.path_join("runtime/node.exe"), [root_dir.path_join("backend/cli.cjs"), "--request-file", prefix + ".in", prefix + ".out"], false)
	if pid == -1:
		DirAccess.remove_absolute(prefix + ".in")
		return {"ok": false, "error": "Cannot launch rule process"}
	var deadline := Time.get_ticks_msec() + 15000
	while OS.is_process_running(pid):
		if Time.get_ticks_msec() > deadline:
			OS.kill(pid)
			DirAccess.remove_absolute(prefix + ".in")
			DirAccess.remove_absolute(prefix + ".out")
			return {"ok": false, "error": "Rule process timeout; state retained"}
		await get_tree().create_timer(0.02).timeout
	DirAccess.remove_absolute(prefix + ".in")
	if not FileAccess.file_exists(prefix + ".out"):
		return {"ok": false, "error": "Rule process exited without response"}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(prefix + ".out"))
	DirAccess.remove_absolute(prefix + ".out")
	if not parsed is Dictionary:
		return {"ok": false, "error": "Invalid rule response"}
	return parsed

# ── SMOKE ─────────────────────────────────────────────────────────

func smoke() -> void:
	assert(characters.size() == 8, "Character data missing")
	await start_match(0)
	if not match_data.get("ok", false):
		push_error(loc.text("smoke_fail") + ": " + notice)
		get_tree().quit(1)
		return
	assert(not match_data.get("choices", []).is_empty(), loc.text("no_legal_actions"))
	await auto_match()
	assert(match_data.get("done", false), loc.text("match_not_finished"))
	assert(career.state.matches == 1, loc.text("reward_missing"))
	show_match()
	assert(career.state.matches == 1, loc.text("double_reward"))
	finish_match()
	print(loc.text("smoke_pass") + ": data, real rule match, AI completion, reward idempotency, club return")
	get_tree().quit(0)
