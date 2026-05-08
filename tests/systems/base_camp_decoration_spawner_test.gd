extends SceneTree

const BaseCampDecorationSpawnerScript: GDScript = preload("res://scripts/systems/base_camp_decoration_spawner.gd")


func _init() -> void:
	var world := Node2D.new()
	root.add_child(world)

	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var blocked_zones: Array = []
	var shelter_pos := Vector2(1500, 1000)

	BaseCampDecorationSpawnerScript.scatter(
		world,
		rng,
		Vector2(3000, 2000),
		shelter_pos,
		blocked_zones
	)

	var expected_count: int = (
		BaseCampDecorationSpawnerScript.TREE_COUNT
		+ BaseCampDecorationSpawnerScript.ROCK_COUNT
	)
	if world.get_child_count() != expected_count:
		push_error("Expected %d decorations, got %d." % [expected_count, world.get_child_count()])
		quit(1)
		return

	if blocked_zones.size() != expected_count:
		push_error("Expected %d blocked zones, got %d." % [expected_count, blocked_zones.size()])
		quit(1)
		return

	for zone in blocked_zones:
		if not zone.has("pos") or not zone.has("radius"):
			push_error("Blocked zone should include position and radius.")
			quit(1)
			return
		if zone["pos"].distance_to(shelter_pos) < BaseCampDecorationSpawnerScript.SHELTER_ROCK_CLEARANCE:
			push_error("Decoration blocker spawned too close to the shelter.")
			quit(1)
			return

	print("Base camp decoration spawner test passed.")
	quit(0)
