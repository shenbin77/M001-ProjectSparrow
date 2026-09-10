extends RefCounted

const Skills = preload("res://skills.gd")
const Campaign = preload("res://campaign.gd")
const VERSION = 3
var state: Dictionary = {}
var _events: Array = []

func _load_events() -> void:
	if not _events.is_empty():
		return
	var root_dir := ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir() if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()
	var path := root_dir.path_join("data/story_events.json")
	if not FileAccess.file_exists(path):
		return
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if raw is Dictionary and raw.has("events") and raw.events is Array:
		for entry in raw.events:
			if entry is Dictionary and entry.has("id") and entry.has("at_match"):
				_events.append(entry)

func event_snapshot() -> Dictionary:
	_load_events()
	var active: Dictionary = {}
	for entry in _events:
		if entry.at_match > state.matches or state.events_seen.has(entry.id):
			continue
		if active.is_empty() or int(entry.at_match) < int(active.at_match):
			active = entry
	if active.is_empty():
		return {}
	var snapshot: Dictionary = {
		"id": active.id, "title": active.title, "body": active.body, "description": active.body,
		"at_match": active.at_match, "choices": active.get("choices", []).duplicate(true)
	}
	return snapshot

func choose_event(choice_id: String) -> bool:
	var event := event_snapshot()
	if event.is_empty():
		return false
	var choice: Variant = {}
	for candidate in event.choices:
		if candidate.id == choice_id:
			choice = candidate
			break
	if choice.is_empty():
		return false
	if int(state.funds) + int(choice.funds) < 0:
		return false
	state.funds += int(choice.funds)
	state.morale = clampi(int(state.morale) + int(choice.morale), 0, 100)
	state.relationships[choice.relationship_id] = int(state.relationships.get(choice.relationship_id, 0)) + int(choice.relationship_delta)
	state.events_seen.append(event.id)
	return true

func _init() -> void:
	state = {"schema_version": VERSION, "funds": 600, "reputation": 0, "roster": ["p01", "p02"],
		"xp": {"p01": 0, "p02": 0}, "skills": {"p01": ["", "", "", ""], "p02": ["", "", "", ""]},
		"learned": {"p01": [], "p02": []}, "active_player": "p01",
		"settled": [], "story": "", "matches": 0, "campaign": Campaign.initial(), "events_seen": [], "morale": 60, "relationships": {}, "tutorial_done": false}

func _migrate_v1(d: Dictionary) -> Dictionary:
	d["learned"] = {}
	d["active_player"] = d.roster[0]
	for id in d["roster"]:
		d["skills"][id] = ["", "", "", ""]
		d["learned"][id] = Skills.available(0)
	return d

func select_player(id: String) -> bool:
	if not state.roster.has(id):
		return false
	state.active_player = id
	return true

func skill_catalog() -> Array:
	return Skills.catalog()

func learned_skills(id: String) -> Array:
	if not state.learned.has(id):
		return []
	return state.learned[id]

func learn_skill(id: String, skill: String) -> bool:
	if not state.roster.has(id) or not state.learned.has(id):
		return false
	if skill == "" or not Skills.valid_id(skill):
		return false
	if state.learned[id].has(skill):
		return false
	if not Skills.available(state.xp[id]).has(skill):
		return false
	var cost := 0
	for s: Dictionary in Skills.catalog():
		if s["id"] == skill:
			cost = s["cost"]
			break
	if state.funds < cost:
		return false
	state.funds -= cost
	state.learned[id].append(skill)
	return true

func train(id: String) -> bool:
	if not state.roster.has(id):
		return false
	var equipped: Array = state.skills[id]
	var cost := Skills.training_cost(equipped)
	if state.funds < cost:
		return false
	var xp_gain := Skills.training_xp(equipped)
	state.funds -= cost
	state.xp[id] += xp_gain
	return true

func recruit(id: String) -> bool:
	if state.roster.has(id) or state.funds < 240:
		return false
	if id not in ["p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08"]:
		return false
	state.funds -= 240
	state.roster.append(id)
	state.xp[id] = 0
	state.skills[id] = ["", "", "", ""]
	state.learned[id] = Skills.available(0)
	return true

func equip(id: String, slot: int, skill: String) -> bool:
	if not state.roster.has(id) or slot < 0 or slot > 3:
		return false
	if skill != "" and not state.learned.has(id):
		return false
	if skill != "" and not state.learned[id].has(skill):
		return false
	if skill != "" and state.skills[id].has(skill) and state.skills[id][slot] != skill:
		return false
	state.skills[id][slot] = skill
	return true

func settle(match_id: String, won: bool) -> bool:
	if match_id.is_empty() or match_id.length() > 100 or state.settled.has(match_id):
		return false
	state.settled.append(match_id)
	state.matches += 1
	state.funds += 260 if won else 100
	state.reputation += 2 if won else 1
	for id in state.roster:
		state.xp[id] += 60 if won else 25
	var bonus := Skills.reward_bonus(state.skills[state.active_player], won)
	state.funds += bonus
	return true

func story_choice(choice: String) -> bool:
	if state.story != "" or choice not in ["sponsor", "community"]:
		return false
	state.story = choice
	if choice == "sponsor":
		state.funds += 180
	else:
		state.reputation += 2
	return true

func valid(value: Variant, ids: Array) -> bool:
	if not value is Dictionary:
		return false
	var required := ["schema_version", "funds", "reputation", "roster", "xp", "skills", "settled", "story", "matches"]
	for key in required:
		if not value.has(key):
			return false
	var sv: Variant = value["schema_version"]
	if not (sv is int or sv is float) or not is_finite(float(sv)) or sv != floor(sv) or int(sv) < 1 or int(sv) > VERSION:
		return false
	if not value.roster is Array or value.roster.is_empty() or value.roster.size() > ids.size():
		return false
	for key in ["funds", "reputation", "matches"]:
		if not (value[key] is float or value[key] is int) or value[key] < 0 or value[key] > 100000000 or value[key] != floor(value[key]):
			return false
	if not value.xp is Dictionary or not value.skills is Dictionary or not value.settled is Array or value.story not in ["", "sponsor", "community"]:
		return false
	var seen: Array = []
	for id in value.roster:
		if not id is String or not ids.has(id) or seen.has(id) or not value.xp.has(id) or not value.skills.has(id):
			return false
		seen.append(id)
		var experience: Variant = value.xp[id]
		if not (experience is int or experience is float) or experience < 0 or experience > 100000000 or experience != floor(experience):
			return false
		if not value.skills[id] is Array or value.skills[id].size() != 4:
			return false
		for sk in value.skills[id]:
			if not sk is String or sk.length() > 100:
				return false
	var has_learned: bool = value.has("learned") and value.has("active_player")
	if int(sv) >= 2 and not has_learned:
		return false
	if has_learned:
		if not value.learned is Dictionary or not value.active_player is String:
			return false
		if not value.roster.has(value.active_player):
			return false
		for id in value.roster:
			if not value.learned.has(id):
				return false
			if not value.learned[id] is Array:
				return false
			var available := Skills.available(int(value.xp[id]))
			for sk in value.learned[id]:
				if not sk is String or not Skills.valid_id(sk) or not available.has(sk):
					return false
			for sk in value.skills[id]:
				if sk != "" and not value.learned[id].has(sk):
					return false
	for id in value.settled:
		if not id is String or id.length() > 100:
			return false
	if int(sv) >= 3:
		if not Campaign.valid(value.get("campaign")) or not value.get("events_seen") is Array or not value.get("relationships") is Dictionary:
			return false
		if not (value.get("morale") is int or value.get("morale") is float) or value.morale < 0 or value.morale > 100 or value.morale != floor(value.morale):
			return false
		if not value.get("tutorial_done") is bool:
			return false
	return true

func save_to(path: String) -> Error:
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(state))
	file.flush()
	file.close()
	if FileAccess.file_exists(path):
		var backup := DirAccess.copy_absolute(path, path + ".bak")
		if backup != OK:
			return backup
	return DirAccess.rename_absolute(path + ".tmp", path)

func load_from(path: String, ids: Array) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return false
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return false
	var sv_in: int = int(parsed.get("schema_version", 0))
	if sv_in < 1 or sv_in > VERSION:
		return false
	if sv_in == 1:
		parsed = _migrate_v1(parsed)
	# Fill any missing fields with safe defaults (add-only, never clobber real values)
	# so that pre-v3 or partial saves still load; genuinely broken values still fail valid().
	if not parsed.has("active_player"):
		var roster_now: Array = parsed.get("roster", [])
		parsed["active_player"] = roster_now[0] if not roster_now.is_empty() else "p01"
	if not parsed.has("learned"):
		parsed["learned"] = {}
	for id in parsed.get("roster", []):
		if not parsed.learned.has(id):
			parsed["learned"][id] = Skills.available(int(parsed.get("xp", {}).get(id, 0)))
	if not parsed.has("campaign"):
		parsed["campaign"] = Campaign.initial()
	if not parsed.has("events_seen"):
		parsed["events_seen"] = []
	if not parsed.has("morale"):
		parsed["morale"] = 60
	if not parsed.has("relationships"):
		parsed["relationships"] = {}
	if not parsed.has("tutorial_done"):
		parsed["tutorial_done"] = false
	parsed["schema_version"] = VERSION
	if not valid(parsed, ids):
		return false
	state = parsed
	for key in ["schema_version", "funds", "reputation", "matches"]:
		state[key] = int(state[key])
	for id in state.roster:
		state.xp[id] = int(state.xp[id])
	return true

func campaign_snapshot() -> Dictionary:
	return Campaign.snapshot(state.campaign)

func settle_result(match_id: String, scores: Array) -> bool:
	var next: Dictionary = state.campaign.duplicate(true)
	if state.settled.has(match_id) or not Campaign.advance(next, scores):
		return false
	if not settle(match_id, scores[0] > 25000):
		return false
	state.campaign = next
	if next.completed and next.promoted:
		state.funds += 500
		state.reputation += 5
	return true

func start_next_season() -> bool:
	return Campaign.next_season(state.campaign)
