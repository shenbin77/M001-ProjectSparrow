extends RefCounted

const CLUBS = ["Crimson Sparrow", "Dockside Union", "White Crane Academy", "Black Dragon Hall", "Tide Analytics"]
const TITLES = ["Street Circuit", "Lanhai City League", "Professional Qualifier", "Regional Invitational"]
const ROUNDS = 12

static func initial() -> Dictionary:
	return {"season": 1, "tier": 0, "round": 0, "totals": [0, 0, 0, 0, 0], "played": [0, 0, 0, 0, 0], "completed": false, "promoted": false}

static func fixture(c: Dictionary) -> Array:
	var venue: int = (int(c.round) / 3) % 4
	return [0, 1 + venue, 1 + (venue + 1) % 4, 1 + (venue + 2) % 4]

static func snapshot(c: Dictionary) -> Dictionary:
	var table: Array = []
	for i in range(5):
		var played: int = int(c.played[i])
		var average: float = float(c.totals[i]) / max(1, played)
		table.append({"id": i, "name": CLUBS[i], "points": average, "total": c.totals[i], "played": played})
	table.sort_custom(func(a: Dictionary, b: Dictionary): return a.points > b.points if a.points != b.points else a.id < b.id)
	return {"round": int(c.round), "season": int(c.season), "tier": int(c.tier), "title": TITLES[min(int(c.tier), 3)], "standings": table, "next_opponent": CLUBS[fixture(c)[1]], "opponent_index": fixture(c)[1] - 1, "completed": c.completed, "promoted": c.promoted, "rounds": ROUNDS}

static func advance(c: Dictionary, scores: Array) -> bool:
	if c.completed or scores.size() != 4:
		return false
	var total := 0
	for score in scores:
		if not (score is int or score is float) or not is_finite(float(score)) or score != floor(score):
			return false
		total += int(score)
	if total != 100000:
		return false
	var seats := [0, 1, 2, 3]
	seats.sort_custom(func(a: int, b: int): return scores[a] > scores[b] if scores[a] != scores[b] else a < b)
	var entrants := fixture(c)
	for rank in range(4):
		var seat: int = seats[rank]
		var team: int = entrants[seat]
		# Invitational circuit rating: point difference plus published placement bonus.
		c.totals[team] += (float(scores[seat]) - 25000.0) / 1000.0 + [15, 5, -5, -15][rank]
		c.played[team] += 1
	c.round += 1
	if c.round == ROUNDS:
		c.completed = true
		var table: Array = snapshot(c).standings
		c.promoted = table[0].id == 0 or table[1].id == 0
	return true

static func next_season(c: Dictionary) -> bool:
	if not c.completed:
		return false
	var season: int = int(c.season) + 1
	var tier: int = mini(3, int(c.tier) + (1 if c.promoted else 0))
	c.merge(initial(), true)
	c.season = season
	c.tier = tier
	return true

static func valid(c: Variant) -> bool:
	if not c is Dictionary:
		return false
	for key in ["season", "tier", "round", "totals", "played", "completed", "promoted"]:
		if not c.has(key):
			return false
	for key in ["season", "tier", "round"]:
		if not (c[key] is int or c[key] is float) or not is_finite(float(c[key])) or c[key] != floor(c[key]):
			return false
	if c.season < 1 or c.season > 10000 or c.tier < 0 or c.tier > 3 or c.round < 0 or c.round > ROUNDS:
		return false
	if not c.completed is bool or not c.promoted is bool or c.completed != (c.round == ROUNDS):
		return false
	if not c.totals is Array or not c.played is Array or c.totals.size() != 5 or c.played.size() != 5:
		return false
	for i in range(5):
		if not (c.totals[i] is int or c.totals[i] is float) or not is_finite(float(c.totals[i])) or abs(c.totals[i]) > 100000:
			return false
		if not (c.played[i] is int or c.played[i] is float) or c.played[i] < 0 or c.played[i] > ROUNDS or c.played[i] != floor(c.played[i]):
			return false
	return int(c.played[0]) == int(c.round)
