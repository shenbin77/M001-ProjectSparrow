extends SceneTree

const Career = preload("res://career.gd")
var count := 0
var failures := 0

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
	check(c.equip("p01", 3, "Focus"), "Slot four unavailable")
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
	check(fresh.state == c.state, "Roundtrip differs")
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
	print("CAREER_TEST_RESULT: %d passed, %d failed" % [count, failures])
	quit(1 if failures else 0)
