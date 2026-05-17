class_name BaseCampWorldBuilder
extends RefCounted

const BaseCampBuildingFactoryScript: GDScript = preload("res://scripts/systems/base_camp_building_factory.gd")
const BaseCampDecorationSpawnerScript: GDScript = preload("res://scripts/systems/base_camp_decoration_spawner.gd")
const CameraControllerScript: GDScript = preload("res://scripts/systems/camera_controller.gd")


static func build(
	root: Node,
	map_size: Vector2,
	shelter_pos: Vector2,
	blocked_zones: Array,
	shelter_tapped: Callable
) -> Dictionary:
	var refs: Dictionary = {}

	var world := Node2D.new()
	root.add_child(world)
	refs["world"] = world

	var grass := TextureRect.new()
	grass.texture = load("res://assets/environment/Background0.png")
	grass.stretch_mode = TextureRect.STRETCH_TILE
	grass.size = map_size
	grass.custom_minimum_size = map_size
	grass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world.add_child(grass)
	refs["grass"] = grass

	var camera := Camera2D.new()
	camera.position = shelter_pos
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(map_size.x)
	camera.limit_bottom = int(map_size.y)
	root.add_child(camera)
	refs["camera"] = camera

	var camera_controller: CameraController = CameraControllerScript.new()
	camera_controller.setup(camera)
	refs["camera_controller"] = camera_controller

	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	BaseCampDecorationSpawnerScript.scatter(world, rng, map_size, shelter_pos, blocked_zones)

	var shelter: StaticBody2D = BaseCampBuildingFactoryScript.make(
		world,
		"shelter",
		shelter_pos,
		"Humble Shelter",
		true
	)
	shelter.tapped.connect(shelter_tapped)
	blocked_zones.append({"pos": shelter_pos, "radius": 85.0})
	refs["shelter"] = shelter

	return refs
