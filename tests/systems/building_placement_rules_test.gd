extends SceneTree

const BuildingPlacementRulesScript: GDScript = preload("res://scripts/systems/building_placement_rules.gd")


func _init() -> void:
	var blocked_zones := [
		{"pos": Vector2(100, 100), "radius": 50.0},
		{"pos": Vector2(300, 100), "radius": 25.0},
	]

	if BuildingPlacementRulesScript.can_place_at(Vector2(120, 100), blocked_zones):
		push_error("Placement inside a blocked radius should fail.")
		quit(1)
		return

	if not BuildingPlacementRulesScript.can_place_at(Vector2(180, 100), blocked_zones):
		push_error("Placement outside blocked radii should pass.")
		quit(1)
		return

	if BuildingPlacementRulesScript.can_place_at(Vector2(300, 124), blocked_zones):
		push_error("Placement near the second blocked radius should fail.")
		quit(1)
		return

	print("Building placement rules test passed.")
	quit(0)
