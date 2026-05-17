class_name SpreadTheFaithRewards
extends RefCounted


static func resolve(rng: RandomNumberGenerator, preacher_count: int, available_capacity: int) -> Dictionary:
	var brought := roll_believers(rng, preacher_count)
	var joined: int = mini(brought, maxi(available_capacity, 0))
	return {
		"brought": brought,
		"joined": joined,
		"text": result_text(brought, joined),
	}


static func roll_believers(rng: RandomNumberGenerator, preacher_count: int) -> int:
	var brought := 0
	for i in range(preacher_count):
		brought += _roll_single_preacher(rng.randf())
	return brought


static func result_text(brought: int, joined: int) -> String:
	if joined <= 0 and brought <= 0:
		return "The crowd was unmoved this time...\nYour preachers return to rest."
	if joined < brought:
		return "%d soul%s wished to join, but your shelters\nare full! Build more to welcome them.\n%d joined anyway." % [
			brought,
			"s" if brought > 1 else "",
			joined,
		]

	var s := "s" if joined > 1 else ""
	return "%d new soul%s have joined your faith!\nThey make their way to your shelter." % [joined, s]


static func _roll_single_preacher(roll: float) -> int:
	if roll < 0.20:
		return 0
	if roll < 0.60:
		return 1
	if roll < 0.90:
		return 2
	return 3
