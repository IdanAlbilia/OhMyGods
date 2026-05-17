extends SceneTree

const BaseCampBuildingFactoryScript: GDScript = preload("res://scripts/systems/base_camp_building_factory.gd")


func _init() -> void:
	var world := Node2D.new()
	root.add_child(world)

	var temple: StaticBody2D = BaseCampBuildingFactoryScript.make(
		world,
		"temple",
		Vector2(120, 240),
		"Small Temple",
		true
	)
	if temple == null or temple.get_parent() != world:
		push_error("Factory should add created buildings to the world.")
		quit(1)
		return
	if temple.building_type != "temple" or temple.building_label != "Small Temple":
		push_error("Factory should assign building type and label.")
		quit(1)
		return
	if not temple.is_interactive or temple.position != Vector2(120, 240):
		push_error("Factory should assign interaction and position state.")
		quit(1)
		return

	var ghost: StaticBody2D = BaseCampBuildingFactoryScript.make_ghost(
		world,
		"missing_type",
		Vector2(10, 20)
	)
	if ghost == null or ghost.get_parent() != world:
		push_error("Factory should create fallback ghosts for unknown types.")
		quit(1)
		return
	if ghost.is_interactive or ghost.building_label != "":
		push_error("Ghost buildings should be non-interactive and unlabeled.")
		quit(1)
		return

	print("Base camp building factory test passed.")
	quit(0)
