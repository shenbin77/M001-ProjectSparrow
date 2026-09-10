extends RefCounted

const VERSION = 1
var state: Dictionary = {}

func _init() -> void:
	state = {"schema_version": VERSION, "funds": 600, "reputation": 0, "roster": ["p01", "p02"], "xp": {"p01": 0, "p02": 0}, "skills": {"p01": ["", "", "", ""], "p02": ["", "", "", ""]}, "settled": [], "story": "", "matches": 0}

func train(id: String) -> bool:
	if not state.roster.has(id) or state.funds < 80:
		return false
	state.funds -= 80
	state.xp[id] += 35
	return true

func recruit(id: String) -> bool:
	if state.roster.has(id) or state.funds < 240:
		return false
	state.funds -= 240
	state.roster.append(id)
	state.xp[id] = 0
	state.skills[id] = ["", "", "", ""]
	return true

func equip(id: String, slot: int, skill: String) -> bool:
	if not state.roster.has(id) or slot < 0 or slot > 3:
		return false
	state.skills[id][slot] = skill
	return true

func settle(match_id: String, won: bool) -> bool:
	if state.settled.has(match_id):
		return false
	state.settled.append(match_id)
	state.matches += 1
	state.funds += 260 if won else 100
	state.reputation += 2 if won else 1
	for id in state.roster:
		state.xp[id] += 60 if won else 25
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
	for key in ["schema_version", "funds", "reputation", "roster", "xp", "skills", "settled", "story", "matches"]:
		if not value.has(key):
			return false
	if value.schema_version != VERSION or not value.roster is Array or value.roster.is_empty() or value.roster.size() > ids.size():
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
		for skill in value.skills[id]:
			if not skill is String or skill.length() > 100:
				return false
	for id in value.settled:
		if not id is String or id.length() > 100:
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
	if not valid(parsed, ids):
		return false
	state = parsed
	for key in ["schema_version", "funds", "reputation", "matches"]:
		state[key] = int(state[key])
	for id in state.roster:
		state.xp[id] = int(state.xp[id])
	return true
