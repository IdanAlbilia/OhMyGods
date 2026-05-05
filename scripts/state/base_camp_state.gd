class_name BaseCampState
extends RefCounted

const BUILDING_SCRIPT := preload("res://scripts/entities/building.gd")
const BELIEVER_SCENE := preload("res://scenes/believer.tscn")
const MARCUS_SCENE := preload("res://scenes/entities/marcus_character.tscn")

const RESTORED_BUILD_TYPES := [
	"temple",
	"hall_of_devoted",
	"preacher_shelter",
	"armory",
	"garrison",
	"generals_quarters",
	"shelter",
	"well",
	"garden",
	"stone_pool",
]

static func capture(game: Node) -> Dictionary:
	var buildings: Array = []
	for child in game.world.get_children():
		if child is StaticBody2D and child.get_script() == BUILDING_SCRIPT:
			if child == game.shelter:
				continue
			if not RESTORED_BUILD_TYPES.has(child.building_type):
				continue
			buildings.append({
				"type": child.building_type,
				"label": child.building_label,
				"position": child.position,
				"under_construction": child.has_meta("under_construction"),
			})

	return {
		"gold": game.gold,
		"faith": game.faith,
		"believers_count": game.believers_count,
		"preachers_count": game.preachers_count,
		"preachers_in_shelter": game.preachers_in_shelter,
		"preacher_shelter_built": game.preacher_shelter_built,
		"believer_shelter_count": game.believer_shelter_count,
		"believer_capacity": game.believer_capacity,
		"soldiers_count": game.soldiers_count,
		"soldiers_in_garrison": game.soldiers_in_garrison,
		"armory_built": game.armory_built,
		"garrison_built": game.garrison_built,
		"marcus_obtained": game.marcus_obtained,
		"generals_quarters_built": game.generals_quarters_built,
		"tutorial_step": game.tut_step,
		"tutorial_popup_dismissed": game.tut_popup_dismissed,
		"wheel_available": game.wheel_available,
		"wheel_daily_timer": game.wheel_daily_timer,
		"buildings": buildings,
		"roads": game.placed_road_tiles.duplicate(true),
		"active_construction": _capture_active_construction(game),
	}

static func restore(game: Node, state: Dictionary) -> void:
	game.gold = int(state.get("gold", game.gold))
	game.faith = int(state.get("faith", game.faith))
	game.believers_count = int(state.get("believers_count", game.believers_count))
	game.preachers_count = int(state.get("preachers_count", 0))
	game.preachers_in_shelter = int(state.get("preachers_in_shelter", 0))
	game.preacher_shelter_built = bool(state.get("preacher_shelter_built", false))
	game.believer_shelter_count = int(state.get("believer_shelter_count", 1))
	game.believer_capacity = int(state.get("believer_capacity", game.believer_shelter_count * 5))
	game.soldiers_count = int(state.get("soldiers_count", 0))
	game.soldiers_in_garrison = int(state.get("soldiers_in_garrison", 0))
	game.armory_built = bool(state.get("armory_built", false))
	game.garrison_built = bool(state.get("garrison_built", false))
	game.marcus_obtained = bool(state.get("marcus_obtained", false))
	game.generals_quarters_built = bool(state.get("generals_quarters_built", false))
	game.tut_step = int(state.get("tutorial_step", game.tut_step))
	game.tut_popup_dismissed = bool(state.get("tutorial_popup_dismissed", game.tut_popup_dismissed))
	game.wheel_available = bool(state.get("wheel_available", true))
	game.wheel_daily_timer = float(state.get("wheel_daily_timer", 0.0))

	_restore_roads(game, state.get("roads", []))
	_restore_buildings(game, state)
	_restore_people(game)
	_refresh_ui(game)

static func spawn_joined_believers(game: Node, count: int, start_count: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(count):
		var b: CharacterBody2D = BELIEVER_SCENE.instantiate()
		var shelter_pos: Vector2 = _shelter_position_for_index(game, start_count + i)
		var offset := Vector2(rng.randf_range(-35, 35), rng.randf_range(-8, 8))
		game.world.add_child(b)
		b.setup(shelter_pos + Vector2(0, 80) + offset, game.believers.size())
		game.believers.append(b)

static func _capture_active_construction(game: Node) -> Dictionary:
	if game.active_construction_node == null:
		return {}
	return {
		"type": game.active_construction_type,
		"position": game.active_construction_node.position,
		"timer": game.active_construction_timer,
		"max": game.active_construction_max,
	}

static func _restore_roads(game: Node, roads: Array) -> void:
	game.placed_road_tiles.clear()
	for road in roads:
		var spr := Sprite2D.new()
		var type := str(road.get("type", ""))
		spr.texture = game._road_texture(type)
		game.road_rotation_deg = int(road.get("rotation", 0))
		game._apply_road_scale(spr, type)
		spr.position = road.get("position", Vector2.ZERO)
		game.world.add_child(spr)
		game.world.move_child(spr, 1)
		game.placed_road_tiles.append(road.duplicate(true))
	game.road_rotation_deg = 0

static func _restore_buildings(game: Node, state: Dictionary) -> void:
	var active: Dictionary = state.get("active_construction", {})
	for data in state.get("buildings", []):
		var type := str(data.get("type", ""))
		var label := str(data.get("label", _label_for(type)))
		var pos: Vector2 = data.get("position", Vector2.ZERO)
		var b: StaticBody2D = game._make_building(type, pos, label, false)
		game.blocked_zones.append({"pos": pos, "radius": 85.0})
		if bool(data.get("under_construction", false)):
			b.set_meta("under_construction", true)
			b.queue_redraw()
			if active.get("type", "") == type and pos.distance_to(active.get("position", Vector2.ZERO)) < 1.0:
				game.active_construction_node = b
				game.active_construction_type = type
				game.active_construction_timer = float(active.get("timer", 0.0))
				game.active_construction_max = float(active.get("max", 1.0))
				game.construction_panel.visible = true
				game._update_construction_ui()
		else:
			b.is_interactive = true
			_wire_completed_building(game, b, type)

static func _wire_completed_building(game: Node, b: StaticBody2D, type: String) -> void:
	match type:
		"temple":
			game.temple = b
			b.tapped.connect(game._on_temple_tapped)
		"hall_of_devoted":
			game.hall_of_devoted = b
			b.tapped.connect(game._on_hall_tapped)
		"preacher_shelter":
			game.preacher_shelter_building = b
			b.tapped.connect(game._on_preacher_shelter_tapped)
		"armory":
			game.armory = b
			b.tapped.connect(game._on_armory_tapped)
		"garrison":
			game.garrison = b
			b.tapped.connect(game._on_garrison_tapped)
		"generals_quarters":
			game.generals_quarters = b
			b.tapped.connect(game._on_generals_quarters_tapped)
			_spawn_marcus(game, b.position)
		"shelter":
			_wire_extra_shelter(game, b)
		"well", "garden", "stone_pool":
			var building_ref := b
			b.tapped.connect(func(): game._show_building_info(building_ref, building_ref.building_label))

static func _wire_extra_shelter(game: Node, b: StaticBody2D) -> void:
	var shelter_ref := b
	game.extra_shelter_buildings.append(b)
	b.tapped.connect(func():
		game.shelter_panel.visible = false
		game.conversion_panel.visible = false
		game.training_panel.visible = false
		game.preacher_shelter_panel.visible = false
		game.garrison_panel.visible = false
		game.current_extra_shelter_idx = game.extra_shelter_buildings.find(shelter_ref) + 1
		game._refresh_extra_shelter_panel()
		game.extra_shelter_panel.visible = true
	)

static func _restore_people(game: Node) -> void:
	game.believers.clear()
	game.preachers.clear()
	game.soldiers.clear()
	_spawn_believers(game)
	_spawn_preachers(game)
	_spawn_soldiers(game)

static func _spawn_believers(game: Node) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(game.believers_count):
		var b: CharacterBody2D = BELIEVER_SCENE.instantiate()
		var shelter_pos: Vector2 = _shelter_position_for_index(game, i)
		var offset := Vector2(rng.randf_range(-35, 35), rng.randf_range(-8, 8))
		game.world.add_child(b)
		b.setup(shelter_pos + Vector2(0, 80) + offset, i)
		game.believers.append(b)

static func _spawn_preachers(game: Node) -> void:
	var home: Vector2 = game.SHELTER_POS
	if game.preacher_shelter_building != null:
		home = game.preacher_shelter_building.position
	elif game.hall_of_devoted != null:
		home = game.hall_of_devoted.position
	for i in range(game.preachers_count):
		var p: CharacterBody2D = BELIEVER_SCENE.instantiate()
		game.world.add_child(p)
		p.setup(home + Vector2(randf_range(-30, 30), 70 + randf_range(-8, 8)), i)
		p.is_preacher = true
		p.queue_redraw()
		game.preachers.append(p)

static func _spawn_soldiers(game: Node) -> void:
	if game.garrison == null and game.armory == null:
		return
	var home: Vector2 = game.garrison.position if game.garrison != null else game.armory.position
	for i in range(game.soldiers_in_garrison):
		var s: CharacterBody2D = BELIEVER_SCENE.instantiate()
		game.world.add_child(s)
		s.setup(home + Vector2(randf_range(-30, 30), 70 + randf_range(-8, 8)), i)
		s.convert_to_soldier()
		game.soldiers.append(s)

static func _spawn_marcus(game: Node, pos: Vector2) -> void:
	if not game.marcus_obtained:
		return
	game.marcus_character_node = MARCUS_SCENE.instantiate()
	game.world.add_child(game.marcus_character_node)
	game.marcus_character_node.setup(pos + Vector2(0, 20))

static func _shelter_position_for_index(game: Node, index: int) -> Vector2:
	var shelter_idx: int = int(index / 5)
	if shelter_idx == 0:
		return game.SHELTER_POS
	if shelter_idx - 1 < game.extra_shelter_buildings.size():
		return game.extra_shelter_buildings[shelter_idx - 1].position
	return game.SHELTER_POS

static func _refresh_ui(game: Node) -> void:
	game._refresh_resource_labels()
	if game.shelter_preacher_label != null:
		game._refresh_preacher_label()
	if game.garrison_soldier_label != null:
		game.garrison_soldier_label.text = "%d / 5" % game.soldiers_in_garrison
	if game.hero_deck_chip != null:
		game.hero_deck_chip.visible = game.marcus_obtained
	if game.build_menu != null:
		game.build_menu.set_generals_quarters_unlocked(game.marcus_obtained)
	if game.wheel_chip_node != null:
		game.wheel_chip_node.visible = game.wheel_available

static func _label_for(type: String) -> String:
	match type:
		"temple": return "Small Temple"
		"hall_of_devoted": return "Hall of the Devoted"
		"preacher_shelter": return "Preacher Shelter"
		"armory": return "Barracks"
		"garrison": return "Garrison"
		"generals_quarters": return "General's Quarters"
		"shelter": return "Believer Shelter"
		"well": return "Wishing Well"
		"garden": return "Pumpkin Garden"
		"stone_pool": return "Stone Pool"
	return "Building"
