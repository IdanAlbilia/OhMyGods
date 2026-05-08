class_name BaseCampBuildingFactory
extends RefCounted

const BUILDING_SCENES := {
	"shelter": preload("res://scenes/buildings/shelter.tscn"),
	"temple": preload("res://scenes/buildings/temple.tscn"),
	"hall_of_devoted": preload("res://scenes/buildings/hall_of_devoted.tscn"),
	"preacher_shelter": preload("res://scenes/buildings/preacher_shelter.tscn"),
	"armory": preload("res://scenes/buildings/armory.tscn"),
	"garrison": preload("res://scenes/buildings/garrison.tscn"),
	"generals_quarters": preload("res://scenes/buildings/generals_quarters.tscn"),
	"well": preload("res://scenes/buildings/well.tscn"),
	"garden": preload("res://scenes/buildings/garden.tscn"),
	"stone_pool": preload("res://scenes/buildings/stone_pool.tscn"),
}


static func make(
	world: Node2D,
	type: String,
	pos: Vector2,
	label: String,
	interactive: bool
) -> StaticBody2D:
	var building := _instantiate(type)
	building.building_type = type
	building.building_label = label
	building.is_interactive = interactive
	building.position = pos
	world.add_child(building)
	return building


static func make_ghost(world: Node2D, type: String, pos: Vector2) -> StaticBody2D:
	var ghost := _instantiate(type)
	ghost.building_type = type
	ghost.building_label = ""
	ghost.is_interactive = false
	ghost.modulate = Color(0.60, 1.0, 0.60, 0.55)
	ghost.position = pos
	world.add_child(ghost)
	return ghost


static func _instantiate(type: String) -> StaticBody2D:
	var scene: PackedScene = BUILDING_SCENES.get(type, BUILDING_SCENES["shelter"])
	return scene.instantiate() as StaticBody2D
