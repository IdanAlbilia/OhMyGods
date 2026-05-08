class_name BuildingPlacementRules
extends RefCounted


static func can_place_at(pos: Vector2, blocked_zones: Array) -> bool:
	for zone in blocked_zones:
		if pos.distance_to(zone["pos"]) < zone["radius"]:
			return false
	return true
