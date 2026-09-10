extends SceneTree
const Career = preload("res://career.gd")
var fails := 0
var checks := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		fails += 1
		push_error(message)
func _initialize() -> void:
	var c = Career.new()
	check(not c.recruit("p1x"), "strict player ID")
	check(not c.equip("p01", 0, "fake"), "unknown skill rejected")
	check(c.learn_skill("p01", "power_training"), "learn level1")
	check(c.equip("p01", 0, "power_training"), "equip learned")
	check(not c.equip("p01", 1, "power_training"), "no duplicate equipment")
	c.state.funds = 40
	check(c.train("p01"), "discount permits 40-fund training")
	check(c.state.funds == 0 and c.state.xp.p01 == 70, "actual skill effect")
	check(not c.learn_skill("p01", "internship"), "locked skill not learned")
	for i in range(12):
		check(c.settle_result("round_%d" % i, [35000, 23000, 22000, 20000]), "real scores advance campaign")
		check(not c.settle_result("round_%d" % i, [35000, 23000, 22000, 20000]), "duplicate result rejected")
	check(c.campaign_snapshot().completed, "season complete")
	var path := "user://progression_test_only.json"
	check(c.save_to(path) == OK, "save v3")
	var fresh = Career.new()
	check(fresh.load_from(path, ["p01", "p02"]), "reload v3")
	check(fresh.campaign_snapshot().completed and fresh.state.matches == 12, "league persisted")
	check(fresh.start_next_season() and fresh.state.campaign.tier == 1, "promotion")
	var legacy: Dictionary = c.state.duplicate(true)
	legacy.schema_version = 1
	legacy.erase("learned")
	legacy.erase("active_player")
	legacy.skills.p01 = ["old name", "", "", ""]
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	check(fresh.load_from(path, ["p01", "p02"]), "v1 migration")
	check(fresh.state.schema_version == 3 and fresh.state.skills.p01[0] == "", "legacy name cleared")
	var invalid: Dictionary = fresh.state.duplicate(true)
	invalid.erase("learned")
	check(not fresh.valid(invalid, ["p01", "p02"]), "new schema missing learned rejected")
	var catalog_ids: Array = []
	for s: Dictionary in Skills.catalog():
		catalog_ids.append(s["id"])
	for old in ["power_training", "speed_drill", "endurance_run", "scholarship_fund", "campus_job", "internship", "study_group", "invest_club"]:
		check(catalog_ids.has(old), "catalog keeps %s" % old)
	for new in ["shanten_drill", "discard_discipline", "defense_reading", "sponsor_negotiation", "media_appearance"]:
		check(catalog_ids.has(new), "catalog adds %s" % new)
	check(Skills.catalog().size() == 13, "catalog holds thirteen entries")
	check(Skills.available(0).has("discard_discipline") and not Skills.available(0).has("shanten_drill"), "level1 boundary")
	check(not Skills.available(99).has("shanten_drill") and Skills.available(100).has("shanten_drill"), "level2 boundary")
	check(not Skills.available(100).has("defense_reading") and Skills.available(200).has("defense_reading"), "level3 boundary")
	check(not Skills.available(200).has("sponsor_negotiation") and Skills.available(300).has("sponsor_negotiation"), "level4 boundary")
	check(not Skills.available(300).has("media_appearance") and Skills.available(400).has("media_appearance"), "level5 boundary")
	check(Skills.training_cost(["shanten_drill"]) == 40 and Skills.training_xp(["shanten_drill"]) == 70, "shanten drill clamps to bounds")
	check(Skills.training_cost(["discard_discipline"]) == 45 and Skills.training_xp(["discard_discipline"]) == 70, "discard discipline in range")
	check(Skills.training_cost(["defense_reading"]) == 40 and Skills.training_xp(["defense_reading"]) == 70, "defense reading clamps to bounds")
	check(Skills.training_cost(["shanten_drill", "discard_discipline"]) == 40 and Skills.training_cost(["discard_discipline", "shanten_drill"]) == 45, "first training slot dominates")
	check(Skills.reward_bonus(["sponsor_negotiation"], true) == 43, "sponsor bonus value")
	check(Skills.reward_bonus(["media_appearance"], true) == 53, "media bonus value")
	check(Skills.reward_bonus(["sponsor_negotiation", "media_appearance"], true) == 60, "economy total clamps at sixty")
	check(Skills.reward_bonus(["media_appearance"], false) == 0, "no bonus when lost")
	check(Skills.reward_bonus(["shanten_drill"], true) == 0, "training skill gives no reward")
	var legacy_old: Dictionary = fresh.state.duplicate(true)
	legacy_old.xp.p01 = 250
	legacy_old.xp.p02 = 0
	legacy_old.learned.p01 = ["power_training", "speed_drill", "endurance_run", "study_group"]
	legacy_old.learned.p02 = ["campus_job"]
	legacy_old.skills.p01 = ["endurance_run", "", "", ""]
	legacy_old.skills.p02 = ["", "", "", ""]
	legacy_old.active_player = "p01"
	check(fresh.valid(legacy_old, ["p01", "p02"]), "learned with old ids only still valid")
	var legacy_locked: Dictionary = legacy_old.duplicate(true)
	legacy_locked.learned.p02 = ["internship"]
	check(not fresh.valid(legacy_locked, ["p01", "p02"]), "locked old id rejected at low xp")
	print("PROGRESSION_TEST_RESULT: %d checks / %d failures" % [checks, fails])
	quit(1 if fails else 0)
