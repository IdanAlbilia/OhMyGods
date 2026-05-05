class_name WheelOfFaith
extends RefCounted

const DAILY_COOLDOWN := 86400.0
const FIRST_SPIN_SEGMENT := 2

const SEGMENTS := [
	{"label": "+50 Gold", "color": Color(0.90, 0.70, 0.10), "type": "gold", "amount": 50},
	{"label": "+20 Faith", "color": Color(0.35, 0.20, 0.75), "type": "faith", "amount": 20},
	{"label": "+100 Gold", "color": Color(0.85, 0.45, 0.05), "type": "gold", "amount": 100},
	{"label": "Dark Omen\n-20 Gold", "color": Color(0.20, 0.10, 0.30), "type": "bad", "amount": -20},
	{"label": "+50 Faith", "color": Color(0.55, 0.18, 0.88), "type": "faith", "amount": 50},
	{"label": "Aldric\nThe Prophet", "color": Color(0.10, 0.45, 0.65), "type": "card", "amount": 0},
	{"label": "+200 Gold", "color": Color(0.95, 0.80, 0.00), "type": "gold", "amount": 200},
	{"label": "Blessing\n+100 Faith", "color": Color(0.72, 0.28, 0.88), "type": "faith", "amount": 100},
]


static func pick_segment(is_first_spin: bool) -> int:
	if is_first_spin:
		return FIRST_SPIN_SEGMENT
	return randi() % SEGMENTS.size()


static func apply_reward(seg_index: int, gold: int, faith: int) -> Dictionary:
	var seg: Dictionary = SEGMENTS[seg_index]
	match seg["type"]:
		"gold":
			gold += int(seg["amount"])
		"faith":
			faith += int(seg["amount"])
		"bad":
			gold = max(0, gold + int(seg["amount"]))

	return {
		"gold": gold,
		"faith": faith,
		"text": result_text(seg),
	}


static func result_text(seg: Dictionary) -> String:
	match seg["type"]:
		"gold":
			return "✦ +%d Gold flows into your treasury!" % int(seg["amount"])
		"faith":
			return "✦ +%d Faith bestowed by the heavens!" % int(seg["amount"])
		"bad":
			return "⚠ Dark Omen! %d Gold was taken..." % abs(int(seg["amount"]))
		"card":
			return "✦ Aldric the Prophet answers your call!\n(Leader cards — coming soon)"
	return "✦ The gods have spoken!"
