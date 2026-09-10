extends Control

const Career = preload("res://career.gd")
var career = Career.new()
var characters: Array = []
var root_dir: String
var page: VBoxContainer
var notice := "Welcome to Lanhai. A fading club. One more chance."
var match_data: Dictionary = {}
var match_id := ""
var club_index := 0
var clubs := ["Dockside Union", "White Crane Academy", "Black Dragon Hall", "Tide Analytics"]
var busy := false
var save_path := "user://career_v1.json"

func _ready() -> void:
	root_dir = ProjectSettings.globalize_path("res://").get_base_dir().get_base_dir()
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(root_dir.path_join("data/characters.json")))
	if raw is Dictionary and raw.has("characters"):
		characters = raw.characters
	var theme := Theme.new()
	theme.default_font_size = 18
	self.theme = theme
	show_club()
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

func clear_page(title: String, subtitle: String) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	add_child(margin)
	var scroll := ScrollContainer.new()
	margin.add_child(scroll)
	page = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 14)
	scroll.add_child(page)
	label("C R I M S O N   S P A R R O W     /     赤雀", 17, Color("d6aa78"))
	label(title, 34, Color("f4ead7"))
	label(subtitle, 16, Color("97a5b4"))
	page.add_child(HSeparator.new())

func label(value: String, size := 18, color := Color("ddd9cd"), parent: Node = null) -> Label:
	var item := Label.new()
	item.text = value
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", size)
	item.add_theme_color_override("font_color", color)
	(parent if parent != null else page).add_child(item)
	return item

func button(value: String, callback: Callable, parent: Node = null, disabled := false) -> Button:
	var item := Button.new()
	item.text = value
	item.custom_minimum_size.y = 44
	item.disabled = disabled
	item.pressed.connect(callback)
	(parent if parent != null else page).add_child(item)
	return item

func row() -> HFlowContainer:
	var item := HFlowContainer.new()
	item.add_theme_constant_override("h_separation", 10)
	page.add_child(item)
	return item

func ids() -> Array:
	return characters.map(func(c): return c.id)

func show_club() -> void:
	clear_page("A dynasty starts with one table.", "DAY 1 BUILD • Single-hand Riichi challenges • Placeholder portraits • Not a release candidate")
	label("CLUB FUNDS  %d     /     REPUTATION  %d     /     MATCHES  %d" % [career.state.funds, career.state.reputation, career.state.matches], 21)
	label(notice, 18, Color("dfb575"))
	var controls := row()
	button("Save career", save_career, controls)
	button("Load career", load_career, controls)
	button("Recover backup", recover_career, controls)
	button("How to play", show_help, controls)
	label("01  /  THE NEXT CHALLENGE", 21)
	for i in range(clubs.size()):
		button("%02d   %s   •   %s" % [i + 1, clubs[i], "Challenge" if career.state.reputation >= i * 2 else "Requires %d reputation" % (i * 2)], start_match.bind(i), null, career.state.reputation < i * 2 or busy)
	label("02  /  YOUR PLAYERS", 21)
	for character in characters:
		if not career.state.roster.has(character.id):
			continue
		var xp: int = int(career.state.xp[character.id])
		label("[ %s ]   %s   •   LV %d   •   XP %d" % [str(character.club).to_upper(), character.name, 1 + xp / 100, xp], 22)
		label(character.style + "\nWants: " + character.desire + "  /  Flaw: " + character.flaw, 16)
		var actions := row()
		button("Train • 80 funds / +35 XP", train.bind(character.id), actions, career.state.funds < 80)
		for slot in range(4):
			var current: String = career.state.skills[character.id][slot]
			button("Slot %d: %s" % [slot + 1, "Equip" if current == "" else current], equip.bind(character.id, slot, character.skills), actions)
	label("03  /  SCOUTING OFFICE", 21)
	label("Direct virtual recruitment • 240 club funds • No real-money purchase or random odds", 16)
	var scouts := row()
	for character in characters:
		if not career.state.roster.has(character.id):
			button("Sign " + character.name, recruit.bind(character.id), scouts, career.state.funds < 240)
	if career.state.story == "":
		label("04  /  KEEP THE LIGHTS ON", 21)
		label("A local sponsor offers emergency cash. Your old regulars ask for a community evening instead. Which promise does the club keep?")
		var options := row()
		button("Sponsor agreement • +180 funds", story.bind("sponsor"), options)
		button("Community evening • +2 reputation", story.bind("community"), options)
	else:
		label("Club promise: " + career.state.story + " • Consequence saved", 16)
	label("Training and skill loadouts are career scaffolding in this build; they do not alter deals or match odds. Opponent strength differentiation is pending.", 15, Color("97a5b4"))

func train(id: String) -> void:
	if busy:
		return
	if career.train(id):
		notice = "Training complete. Experience gained; the wall remains fair."
	show_club()

func recruit(id: String) -> void:
	if busy:
		return
	if career.recruit(id):
		notice = "New contract signed. Welcome to Crimson Sparrow."
	show_club()

func equip(id: String, slot: int, available: Array) -> void:
	if busy:
		return
	var current: String = career.state.skills[id][slot]
	var next: int = (available.find(current) + 1) % available.size()
	career.equip(id, slot, available[next])
	notice = "Loadout changed. Skill effects are not implemented in this development checkpoint."
	show_club()

func story(choice: String) -> void:
	if busy:
		return
	career.story_choice(choice)
	notice = "You chose " + choice + ". This decision can only pay out once."
	show_club()

func save_career() -> void:
	if busy:
		return
	var result: Error = career.save_to(save_path)
	notice = "Career saved. Previous save retained as .bak." if result == OK else "Save failed (%d). Previous save retained." % result
	show_club()

func load_career() -> void:
	if busy:
		return
	notice = "Career loaded." if career.load_from(save_path, ids()) else "Save missing, damaged or incompatible. Nothing overwritten; try Recover backup."
	show_club()

func recover_career() -> void:
	if busy:
		return
	notice = "Backup loaded into memory. Save explicitly to keep it." if career.load_from(save_path + ".bak", ids()) else "No valid backup. Current career unchanged."
	show_club()

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

func start_match(index: int) -> void:
	if busy or career.state.reputation < index * 2:
		return
	club_index = index
	match_id = "%s-%s" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()]
	busy = true
	var data: Dictionary = await request_backend({"op": "new", "seed": randi() % 2147483647})
	busy = false
	if not data.get("ok", false):
		notice = str(data.get("error", "Cannot start match"))
		show_club()
		return
	match_data = data
	show_match()

func show_match() -> void:
	clear_page(clubs[club_index] + " / Challenge Table", "STANDARD RIICHI CORE • A single-hand exhibition • You are player 0 • Scores follow the engine")
	label("Scores  %s     /     Tiles left  %s     /     Dora indicators  %s" % [str(match_data.get("scores", [])), str(match_data.get("wall", 0)), str(match_data.get("dora", []))], 20)
	if match_data.get("done", false):
		var scores: Array = match_data.get("scores", [25000, 25000, 25000, 25000])
		var won: bool = scores[0] > 25000
		label("HAND COMPLETE", 32, Color("dfb575"))
		label("+260 funds / +2 reputation / +60 roster XP" if won else "+100 funds / +1 reputation / +25 roster XP", 22)
		label("Challenge success means positive point gain this hand. Draws and losses still grant participation resources.", 16)
		label(JSON.stringify(match_data.get("result", {})), 15)
		button("Return to club", finish_match)
		return
	var discards: Array = match_data.get("discards", [[], [], [], []])
	for i in range(discards.size()):
		label("SEAT %d   |   %s" % [i, "  ".join(PackedStringArray(discards[i]))], 17)
		label("Open melds: " + str(match_data.get("melds", [[], [], [], []])[i]), 15)
	label("YOUR HAND   •   Seat %s" % str(match_data.get("seat", 0)), 20, Color("dfb575"))
	var hand: String = match_data.get("hand", "")
	var tiles := row()
	var suit := ""
	for ch in hand.split(",")[0]:
		if ch in ["m", "p", "s", "z"]:
			suit = ch
		elif ch.is_valid_int():
			var tile := PanelContainer.new()
			tile.custom_minimum_size = Vector2(57, 72)
			tiles.add_child(tile)
			label(ch + suit, 27, Color("f4ead7"), tile)
	label("m = characters   p = circles   s = bamboo   z = honors; 0 = red five. Raw hand: " + hand, 15)
	label("LEGAL ACTIONS", 20)
	var actions := row()
	for choice in match_data.get("choices", []):
		button(str(choice.label), play.bind(choice.reply), actions, busy)
	button("AI finish this hand (debug / accessibility)", auto_match, null, busy)
	button("Concede • no reward", concede)
	label("No mid-hand save yet. Finish or concede before saving. Closed opponent hands are not displayed.", 15)

func play(reply: Dictionary) -> void:
	await advance({"op": "action", "state": match_data.state, "choice": reply})

func auto_match() -> void:
	await advance({"op": "auto", "state": match_data.state})

func advance(request: Dictionary) -> void:
	if busy:
		return
	busy = true
	var result: Dictionary = await request_backend(request)
	busy = false
	if result.get("ok", false):
		match_data = result
		if match_data.get("done", false):
			var scores: Array = match_data.get("scores", [25000, 25000, 25000, 25000])
			career.settle(match_id, scores[0] > 25000)
		show_match()
	else:
		label("Rule error: " + str(result.get("error", "unknown")) + ". State retained. Retry or concede.", 18, Color("f19183"))

func finish_match() -> void:
	if busy:
		return
	match_data = {}
	notice = "Challenge settled once. Train, recruit, save, then challenge again."
	show_club()

func concede() -> void:
	if busy:
		return
	match_data = {}
	notice = "Match conceded. No rewards issued."
	show_club()

func show_help() -> void:
	if busy:
		return
	clear_page("A club worth coming back to.", "QUICK START / DEVELOPMENT CHECKPOINT")
	label("1. Challenge Dockside Union. Choose a legal discard after drawing. Three AI players take their turns automatically.\n2. Riichi needs a closed, ready hand and 1,000 points. Complete four melds and a pair (or a special hand) with a valid yaku. Dora alone is not a yaku.\n3. When legal, Ron / Tsumo / Chi / Pon / Kan appear among actions. Passing a win can affect furiten; the rule engine enforces it.\n4. Win positive points for a larger club reward. Train for XP and levels, sign players and replace four skill slots.\n5. Reputation unlocks club nodes. Make one story choice, then save outside a match.\n\nThis is a single-hand development build, not a complete career season or release candidate. Skill effects, opponent styles, transfers, retirement and a full tutorial remain on the sprint backlog. Visuals are placeholders.", 21)
	button("Back to club", show_club)

func smoke() -> void:
	assert(characters.size() == 8, "Character data missing")
	await start_match(0)
	if not match_data.get("ok", false):
		push_error("SMOKE_FAILED: " + notice)
		get_tree().quit(1)
		return
	assert(not match_data.get("choices", []).is_empty(), "No legal actions")
	await auto_match()
	assert(match_data.get("done", false), "Match did not finish")
	assert(career.state.matches == 1, "Reward missing")
	show_match()
	assert(career.state.matches == 1, "Double reward")
	finish_match()
	print("GODOT_SMOKE_PASS: data, real rule match, AI completion, reward idempotency, club return")
	get_tree().quit(0)
