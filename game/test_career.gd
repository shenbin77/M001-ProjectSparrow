extends SceneTree

const Career = preload("res://career.gd")
var count := 0
var failures := 0

func same(a: Variant, b: Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for key in a:
			if not b.has(key) or not same(a[key], b[key]):
				return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not same(a[i], b[i]):
				return false
		return true
	return a == b

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1
		return
	count += 1

func _initialize() -> void:
	var c = Career.new()
	check(c.train("p01"), "Training failed")
	check(c.state.funds == 520 and c.state.xp.p01 == 35, "Training wrong delta")
	check(not c.train("invalid"), "Unknown player accepted")
	check(c.recruit("p03"), "Recruit failed")
	check(not c.recruit("p03"), "Duplicate recruit")
	check(c.learn_skill("p01", "power_training"), "Learn eligible skill")
	check(c.equip("p01", 3, "power_training"), "Slot four unavailable")
	check(not c.equip("p01", 4, "Focus"), "Fifth slot accepted")
	check(c.settle("match-a", true), "Reward failed")
	var funds: int = c.state.funds
	check(not c.settle("match-a", true) and c.state.funds == funds, "Duplicate reward")
	check(c.story_choice("community"), "Story failed")
	check(not c.story_choice("sponsor"), "Story replay paid twice")
	var path := "user://test_career_only.json"
	check(c.save_to(path) == OK, "First save failed")
	var fresh = Career.new()
	check(fresh.load_from(path, ["p01", "p02", "p03"]), "Load failed")
	check(same(fresh.state, c.state), "Roundtrip differs")
	check(c.save_to(path) == OK, "Overwrite/backup failed")
	check(FileAccess.file_exists(path + ".bak"), "Backup absent")
	var bad := FileAccess.open(path, FileAccess.WRITE)
	bad.store_string("{broken")
	bad.close()
	var before: Dictionary = fresh.state.duplicate(true)
	check(not fresh.load_from(path, ["p01", "p02", "p03"]), "Corrupt save accepted")
	check(fresh.state == before, "Failed load changed career")
	check(fresh.load_from(path + ".bak", ["p01", "p02", "p03"]), "Backup recovery failed")
	var future: Dictionary = c.state.duplicate(true)
	future.schema_version = 999
	check(not c.valid(future, ["p01", "p02", "p03"]), "Future schema accepted")
	future = c.state.duplicate(true)
	future.funds = -1
	check(not c.valid(future, ["p01", "p02", "p03"]), "Negative funds accepted")
	c.state.funds = 0
	check(not c.train("p01") and not c.recruit("p04"), "Unaffordable spend")
	var no_match = Career.new()
	check(no_match.event_snapshot().is_empty(), "Event visible before first match")
	no_match.state.matches = 1
	check(no_match.event_snapshot().id == "se_001", "se_001 not active without story choice")
	check(c.event_snapshot().id == "se_001", "se_001 not active with story choice")
	check(not c.choose_event("se999_a"), "Unknown event choice accepted")
	check(not c.choose_event("se001_b"), "Unaffordable event choice accepted")
	check(c.state.funds == 0, "Rejected event choice changed funds")
	var seen_before: int = c.state.events_seen.size()
	var morale_before: int = c.state.morale
	check(c.choose_event("se001_a"), "Event choice failed")
	check(c.state.funds == 180, "Event funds delta wrong")
	check(c.state.morale == clampi(morale_before - 8, 0, 100), "Event morale delta wrong")
	check(c.state.relationships.get("p01", 0) == -10, "Event relationship delta wrong")
	check(c.state.events_seen.size() == seen_before + 1 and c.state.events_seen.has("se_001"), "events_seen not updated")
	check(not c.choose_event("se001_a"), "Replayed event choice accepted")
	check(c.event_snapshot().is_empty(), "Later event active too early")
	c.state.matches = 3
	check(not c.choose_event("se001_a"), "Non-active event choice accepted")
	check(c.event_snapshot().id == "se_002", "se_002 not active at match three")
	check(c.save_to(path) == OK, "Event save failed")
	var reloaded = Career.new()
	check(reloaded.load_from(path, ["p01", "p02", "p03"]), "Event load failed")
	check(same(reloaded.state.events_seen, c.state.events_seen), "events_seen not persisted")
	check(same(reloaded.state.relationships, c.state.relationships), "relationships not persisted")
	check(c.valid(reloaded.state, ["p01", "p02", "p03"]), "Reloaded career invalid")
	var partial: Dictionary = c.state.duplicate(true)
	for key in ["events_seen", "relationships", "morale", "tutorial_done", "campaign", "learned", "active_player"]:
		partial.erase(key)
	var legacy_path := "user://test_career_legacy.json"
	var legacy_file := FileAccess.open(legacy_path, FileAccess.WRITE)
	legacy_file.store_string(JSON.stringify(partial))
	legacy_file.close()
	var legacy_career = Career.new()
	check(legacy_career.load_from(legacy_path, ["p01", "p02", "p03"]), "Partial old save rejected")
	check(legacy_career.state.schema_version == 3, "Partial save not upgraded to latest")
	check(legacy_career.state.events_seen is Array and legacy_career.state.relationships is Dictionary and legacy_career.state.morale == 60 and legacy_career.state.active_player == "p01", "Partial save defaults wrong")
	var broken: Dictionary = partial.duplicate(true)
	broken["funds"] = "x"
	var broken_path := "user://test_career_broken.json"
	var broken_file := FileAccess.open(broken_path, FileAccess.WRITE)
	broken_file.store_string(JSON.stringify(broken))
	broken_file.close()
	check(not legacy_career.load_from(broken_path, ["p01", "p02", "p03"]), "Broken value accepted")
	print("CAREER_TEST_RESULT: %d passed, %d failed" % [count, failures])
	quit(1 if failures else 0)
