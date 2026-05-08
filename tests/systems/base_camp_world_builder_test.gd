extends SceneTree

const BaseCampWorldBuilderScript: GDScript = preload("res://scripts/systems/base_camp_world_builder.gd")

var _shelter_tapped := false


func _init() -> void:
	var root_node := Node.new()
	root.add_child(root_node)

	var blocked_zones: Array = []
	var map_size := Vector2(3000, 2000)
	var shelter_pos := Vector2(1500, 1000)
	var refs: Dictionary = BaseCampWorldBuilderScript.build(
		root_node,
		map_size,
		shelter_pos,
		blocked_zones,
		_on_shelter_tapped
	)
	await process_frame

	var world: Node2D = refs["world"]
	var camera: Camera2D = refs["camera"]
	var camera_controller: CameraController = refs["camera_controller"]
	var shelter: StaticBody2D = refs["shelter"]
	var grass: TextureRect = refs["grass"]

	if world == null or camera == null or camera_controller == null or shelter == null or grass == null:
		push_error("World builder should return world, camera, controller, shelter, and grass refs.")
		quit(1)
		return
	if world.get_parent() != root_node or camera.get_parent() != root_node:
		push_error("World builder should add world and camera to the supplied root.")
		quit(1)
		return
	if grass.custom_minimum_size != map_size:
		push_error("World background should match the requested map size.")
		quit(1)
		return
	if camera.position != shelter_pos or camera.limit_right != int(map_size.x) or camera.limit_bottom != int(map_size.y):
		push_error("Camera should be centered on shelter and limited to map bounds.")
		quit(1)
		return
	if shelter.position != shelter_pos or not shelter.is_interactive:
		push_error("Starting shelter should be interactive and placed at shelter position.")
		quit(1)
		return
	if blocked_zones.is_empty():
		push_error("World builder should append blocked zones.")
		quit(1)
		return

	shelter.tapped.emit()
	if not _shelter_tapped:
		push_error("Starting shelter should connect the supplied tapped callback.")
		quit(1)
		return

	root_node.free()
	print("Base camp world builder test passed.")
	quit(0)


func _on_shelter_tapped() -> void:
	_shelter_tapped = true
