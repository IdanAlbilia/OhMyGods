extends SceneTree

const RoadTilesScript: GDScript = preload("res://scripts/systems/road_tiles.gd")


func _init() -> void:
	var road: Sprite2D = RoadTilesScript.make_sprite("road_h", Vector2(12, 34), 90)
	if road.texture == null:
		push_error("Road tile texture was not loaded.")
		quit(1)
		return
	if road.position != Vector2(12, 34):
		push_error("Road tile position was not applied.")
		quit(1)
		return
	if not is_equal_approx(road.rotation_degrees, 90.0):
		push_error("Road tile rotation was not applied.")
		quit(1)
		return
	if road.scale != Vector2(200.0 / 512.0, 72.0 / 512.0):
		push_error("Road tile scale was not applied.")
		quit(1)
		return
	if not RoadTilesScript.is_rotatable("road_t"):
		push_error("T-junction roads should be rotatable.")
		quit(1)
		return
	if RoadTilesScript.is_rotatable("road_h"):
		push_error("Horizontal road should not need the rotate control.")
		quit(1)
		return

	road.free()
	print("Road tiles test passed.")
	quit(0)
