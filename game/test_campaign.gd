extends SceneTree
const Campaign = preload("res://campaign.gd")
var failures := 0
var checks := 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)
func _initialize() -> void:
	var c: Dictionary = Campaign.initial()
	check(Campaign.valid(c), "initial valid")
	check(not Campaign.next_season(c), "cannot skip season")
	check(not Campaign.advance(c, [1, 2, 3, 4]), "must conserve points")
	for i in range(12):
		check(Campaign.advance(c, [35000, 23000, 22000, 20000]), "fixture completes")
		check(Campaign.valid(c), "valid at every round")
	check(c.completed and c.promoted, "season promoted")
	check(not Campaign.advance(c, [25000, 25000, 25000, 25000]), "closed season refuses result")
	check(Campaign.next_season(c) and c.season == 2 and c.tier == 1 and c.round == 0, "next season")
	for i in range(12):
		Campaign.advance(c, [10000, 30000, 30000, 30000])
	check(c.completed and not c.promoted, "loss season no promotion")
	check(Campaign.next_season(c) and c.tier == 1, "loss can continue")
	var damaged: Dictionary = c.duplicate(true)
	damaged.round = 12
	check(not Campaign.valid(damaged), "inconsistent completed rejected")
	print("CAMPAIGN_TEST_RESULT: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
