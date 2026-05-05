class_name CrusadeRewards
extends RefCounted

const RARITY_TIERS := ["Common", "Uncommon", "Rare", "Epic", "Legendary"]


static func roll_box(rng: RandomNumberGenerator) -> Dictionary:
	var roll: float = rng.randf()
	var rarity: String
	if roll < 0.01:
		rarity = "Legendary"
	elif roll < 0.07:
		rarity = "Epic"
	elif roll < 0.20:
		rarity = "Rare"
	elif roll < 0.45:
		rarity = "Uncommon"
	else:
		rarity = "Common"

	return _rewards_for_rarity(rarity, rng)


static func upgrade_box_rarity(box: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var idx: int = RARITY_TIERS.find(box.rarity)
	if idx < 0 or idx >= RARITY_TIERS.size() - 1:
		return box

	var upgraded: Dictionary = _rewards_for_rarity(RARITY_TIERS[idx + 1], rng)
	upgraded["gold"] = maxi(upgraded.gold, box.gold)
	upgraded["faith"] = maxi(upgraded.faith, box.faith)
	return upgraded


static func rarity_color(rarity: String) -> Color:
	match rarity:
		"Common":
			return Color(0.55, 0.55, 0.55)
		"Uncommon":
			return Color(0.20, 0.75, 0.20)
		"Rare":
			return Color(0.25, 0.50, 1.00)
		"Epic":
			return Color(0.65, 0.20, 0.90)
		"Legendary":
			return Color(0.95, 0.65, 0.05)
	return Color(0.55, 0.55, 0.55)


static func _rewards_for_rarity(rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var gold_reward: int
	var faith_reward: int
	var hero_chance: float

	match rarity:
		"Common":
			gold_reward = rng.randi_range(50, 100)
			faith_reward = rng.randi_range(5, 10)
			hero_chance = 0.02
		"Uncommon":
			gold_reward = rng.randi_range(100, 200)
			faith_reward = rng.randi_range(10, 20)
			hero_chance = 0.05
		"Rare":
			gold_reward = rng.randi_range(200, 400)
			faith_reward = rng.randi_range(20, 40)
			hero_chance = 0.10
		"Epic":
			gold_reward = rng.randi_range(400, 800)
			faith_reward = rng.randi_range(40, 80)
			hero_chance = 0.20
		"Legendary":
			gold_reward = rng.randi_range(800, 1500)
			faith_reward = rng.randi_range(80, 150)
			hero_chance = 0.50
		_:
			gold_reward = 50
			faith_reward = 5
			hero_chance = 0.02

	return {
		"rarity": rarity,
		"gold": gold_reward,
		"faith": faith_reward,
		"hero_chance": hero_chance,
	}
