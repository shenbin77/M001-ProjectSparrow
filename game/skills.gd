extends RefCounted
class_name Skills

const SKILLS: Array[Dictionary] = [
	{
		"id": "power_training",
		"name": "Power Training",
		"description": "Brute strength conditioning",
		"effect": "training_xp",
		"unlock_level": 1,
		"cost": 80
	},
	{
		"id": "speed_drill",
		"name": "Speed Drill",
		"description": "Agility and reflex training",
		"effect": "training_xp",
		"unlock_level": 1,
		"cost": 60
	},
	{
		"id": "endurance_run",
		"name": "Endurance Run",
		"description": "Long distance stamina boost",
		"effect": "training_xp",
		"unlock_level": 2,
		"cost": 100
	},
	{
		"id": "scholarship_fund",
		"name": "Scholarship Fund",
		"description": "Financial aid for academics",
		"effect": "economy",
		"unlock_level": 1,
		"cost": 120
	},
	{
		"id": "campus_job",
		"name": "Campus Job",
		"description": "Part-time work on campus",
		"effect": "economy",
		"unlock_level": 1,
		"cost": 50
	},
	{
		"id": "internship",
		"name": "Internship",
		"description": "Real-world paid experience",
		"effect": "economy",
		"unlock_level": 3,
		"cost": 150
	},
	{
		"id": "study_group",
		"name": "Study Group",
		"description": "Peer learning sessions",
		"effect": "training_xp",
		"unlock_level": 2,
		"cost": 70
	},
	{
		"id": "invest_club",
		"name": "Investment Club",
		"description": "Learn to grow your savings",
		"effect": "economy",
		"unlock_level": 3,
		"cost": 180
	},
	{
		"id": "shanten_drill",
		"name": "Shanten Drill",
		"description": "Hand shape decomposition training",
		"effect": "training_xp",
		"unlock_level": 2,
		"cost": 90
	},
	{
		"id": "discard_discipline",
		"name": "Discard Discipline",
		"description": "Strict safe-discard routines",
		"effect": "training_xp",
		"unlock_level": 1,
		"cost": 70
	},
	{
		"id": "defense_reading",
		"name": "Defense Reading",
		"description": "Read the table to defend",
		"effect": "training_xp",
		"unlock_level": 3,
		"cost": 110
	},
	{
		"id": "sponsor_negotiation",
		"name": "Sponsor Negotiation",
		"description": "Better terms from sponsors",
		"effect": "economy",
		"unlock_level": 4,
		"cost": 130
	},
	{
		"id": "media_appearance",
		"name": "Media Appearance",
		"description": "Earn from media exposure",
		"effect": "economy",
		"unlock_level": 5,
		"cost": 160
	}
]

static func catalog() -> Array:
	return SKILLS.duplicate(true)

static func available(xp: int) -> Array:
	var level := 1 + xp / 100
	var result: Array[String] = []
	for s: Dictionary in SKILLS:
		if s["unlock_level"] <= level:
			result.append(s["id"])
	return result

static func training_cost(equipped: Array) -> int:
	var base := 80
	var cost_applied := false
	for s_id: String in equipped:
		if s_id == "":
			continue
		if cost_applied:
			continue
		for s: Dictionary in SKILLS:
			if s["id"] == s_id and s["effect"] == "training_xp":
				base -= s["cost"] / 2
				cost_applied = true
				break
	return maxi(base, 40)

static func training_xp(equipped: Array) -> int:
	var base := 35
	var xp_applied := false
	for s_id: String in equipped:
		if s_id == "":
			continue
		if xp_applied:
			continue
		for s: Dictionary in SKILLS:
			if s["id"] == s_id and s["effect"] == "training_xp":
				base += s["cost"] / 2
				xp_applied = true
				break
	return mini(base, 70)

static func reward_bonus(equipped: Array, won: bool) -> int:
	if not won:
		return 0
	var total := 0
	var seen: Array = []
	for s_id: String in equipped:
		if s_id == "" or seen.has(s_id):
			continue
		seen.append(s_id)
		for s: Dictionary in SKILLS:
			if s["id"] == s_id and s["effect"] == "economy":
				total += s["cost"] / 3
				break
	return mini(total, 60)

static func valid_id(id: String) -> bool:
	if id == "":
		return true
	for s: Dictionary in SKILLS:
		if s["id"] == id:
			return true
	return false
