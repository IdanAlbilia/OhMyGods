extends SceneTree

const BaseCampStateScript: GDScript = preload("res://scripts/state/base_camp_state.gd")


class FakeGame extends Node:
	const SHELTER_POS := Vector2(1500, 1000)

	var world := Node2D.new()
	var gold := 100
	var faith := 100
	var believers_count := 5
	var preachers_count := 0
	var preachers_in_shelter := 0
	var preacher_shelter_built := false
	var believer_shelter_count := 1
	var believer_capacity := 5
	var soldiers_count := 0
	var soldiers_in_garrison := 0
	var armory_built := false
	var garrison_built := false
	var marcus_obtained := false
	var generals_quarters_built := false
	var tut_step := 0
	var tut_popup_dismissed := false
	var wheel_available := true
	var wheel_daily_timer := 0.0
	var placed_road_tiles: Array = []
	var blocked_zones: Array = [{"pos": SHELTER_POS, "radius": 85.0}]
	var believers: Array = []
	var preachers: Array = []
	var soldiers: Array = []
	var extra_shelter_buildings: Array = []

	var shelter: StaticBody2D = null
	var temple: StaticBody2D = null
	var hall_of_devoted: StaticBody2D = null
	var preacher_shelter_building: StaticBody2D = null
	var armory: StaticBody2D = null
	var garrison: StaticBody2D = null
	var generals_quarters: StaticBody2D = null
	var active_construction_node: StaticBody2D = null
	var active_construction_type := ""
	var active_construction_timer := 0.0
	var active_construction_max := 0.0

	var construction_panel = null
	var shelter_panel = null
	var conversion_panel = null
	var training_panel = null
	var preacher_shelter_panel = null
	var garrison_panel = null
	var extra_shelter_panel = null
	var shelter_preacher_label = null
	var garrison_soldier_label = null
	var hero_deck_chip = null
	var build_menu = null
	var wheel_chip_node = null
	var marcus_character_node = null
	var current_extra_shelter_idx := 0

	func _init() -> void:
		add_child(world)

	func _refresh_resource_labels() -> void:
		pass

	func _refresh_preacher_label() -> void:
		pass

	func _update_construction_ui() -> void:
		pass

	func _refresh_extra_shelter_panel() -> void:
		pass

	func _show_building_info(_building: StaticBody2D, _text: String) -> void:
		pass

	func _on_temple_tapped() -> void:
		pass

	func _on_hall_tapped() -> void:
		pass

	func _on_preacher_shelter_tapped() -> void:
		pass

	func _on_armory_tapped() -> void:
		pass

	func _on_garrison_tapped() -> void:
		pass

	func _on_generals_quarters_tapped() -> void:
		pass


func _init() -> void:
	var game := FakeGame.new()
	root.add_child(game)

	BaseCampStateScript.restore(game, {
		"gold": 100,
		"faith": 100,
		"believers_count": 5,
		"preachers_count": 0,
		"preachers_in_shelter": 0,
		"preacher_shelter_built": false,
		"believer_shelter_count": 1,
		"believer_capacity": 5,
		"soldiers_count": 0,
		"soldiers_in_garrison": 0,
		"armory_built": false,
		"garrison_built": false,
		"marcus_obtained": false,
		"generals_quarters_built": false,
		"tutorial_step": 10,
		"tutorial_popup_dismissed": true,
		"wheel_available": true,
		"wheel_daily_timer": 0.0,
		"roads": [],
		"active_construction": {},
		"buildings": [
			{
				"type": "temple",
				"label": "Small Temple",
				"position": Vector2(1200, 900),
				"under_construction": false,
			},
		],
	})

	if game.temple == null:
		push_error("Restored base camp should recreate the saved temple.")
		game.free()
		quit(1)
		return
	if game.temple.get_parent() != game.world:
		push_error("Restored temple should be added to the world.")
		game.free()
		quit(1)
		return
	if game.temple.building_type != "temple" or game.temple.building_label != "Small Temple":
		push_error("Restored temple should keep its type and label.")
		game.free()
		quit(1)
		return
	if not game.temple.is_interactive:
		push_error("Completed restored temple should be interactive.")
		game.free()
		quit(1)
		return
	if game.blocked_zones.size() < 2:
		push_error("Restored buildings should add blocked placement zones.")
		game.free()
		quit(1)
		return

	game.free()
	print("Base camp state restore test passed.")
	quit(0)
