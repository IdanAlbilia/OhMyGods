extends Node

const BaseCampStateScript: GDScript = preload("res://scripts/state/base_camp_state.gd")
const WheelOfFaithScript: GDScript = preload("res://scripts/systems/wheel_of_faith.gd")
const CrusadeRewardsScript: GDScript = preload("res://scripts/systems/crusade_rewards.gd")
const RoadTilesScript: GDScript = preload("res://scripts/systems/road_tiles.gd")
const RoadPlacementControllerScript: GDScript = preload("res://scripts/systems/road_placement_controller.gd")
const CameraControllerScript: GDScript = preload("res://scripts/systems/camera_controller.gd")
const CampaignNavigationControllerScript: GDScript = preload("res://scripts/systems/campaign_navigation_controller.gd")
const TutorialCopyScript: GDScript = preload("res://scripts/ui/tutorial/tutorial_copy.gd")
const BuildingPanelFactoryScript: GDScript = preload("res://scripts/ui/building_panel_factory.gd")
const TopBarFactoryScript: GDScript = preload("res://scripts/ui/top_bar_factory.gd")
const WHEEL_POPUP_SCENE := preload("res://scenes/ui/wheel_of_faith_popup.tscn")
const CRUSADE_RESULT_POPUP_SCENE := preload("res://scenes/ui/crusade_result_popup.tscn")
const BUILD_MENU_SCENE := preload("res://scenes/ui/build_menu.tscn")
const HERO_DECK_PANEL_SCENE := preload("res://scenes/ui/hero_deck_panel.tscn")
const TEMPLE_PANEL_SCENE := preload("res://scenes/ui/temple_panel.tscn")
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
const MARCUS_SCENE := preload("res://scenes/entities/marcus_character.tscn")

# ── Resources ───────────────────────────────────────────────────────────────
var gold: int = 100
var faith: int = 100        # start with 100
var believers_count: int = 5

# ── Wheel of Faith ──────────────────────────────────────────────────────────
var wheel_available: bool = true
var wheel_spinning:  bool = false
var is_first_spin:   bool = true
var wheel_daily_timer: float = 0.0
var wheel_popup = null
var wheel_chip_node: PanelContainer = null

# ── Scene refs ──────────────────────────────────────────────────────────────
var world: Node2D
var shelter: StaticBody2D
var temple: StaticBody2D = null
var hall_of_devoted: StaticBody2D = null
var preacher_shelter_building: StaticBody2D = null
var ghost_node: StaticBody2D = null
var believers := []
var preachers := []   # believer nodes that have been converted

# ── UI refs ─────────────────────────────────────────────────────────────────
# ── Armory / soldiers ────────────────────────────────────────────────────────
var armory: StaticBody2D = null
var garrison: StaticBody2D = null
var soldiers_count: int = 0
var soldiers_in_garrison: int = 0
var armory_built: bool = false
var garrison_built: bool = false
var soldier_waiting_at_armory: bool = false
var soldiers := []
var training_panel: PanelContainer
var training_label: Label
var training_bar: ColorRect
var train_btn: Button
var training_rush_btn: Button
var barracks_soldier_label: Label   # unused — kept to avoid null refs
var garrison_panel: PanelContainer
var garrison_soldier_label: Label
var training: bool = false
var training_timer: float = 0.0
var training_node: CharacterBody2D = null

# ── Camera / panning / zoom ───────────────────────────────────────────────────
const ZOOM_MIN    := 0.40   # furthest out  (sees more of the map)
const ZOOM_MAX    := 2.50   # furthest in   (fine detail)
const ZOOM_FACTOR := 1.12   # multiply per scroll notch
var camera: Camera2D = null
var is_panning := false
var pan_start_mouse := Vector2.ZERO
var pan_start_cam := Vector2.ZERO

# ── UI refs ──────────────────────────────────────────────────────────────────
var gold_label: Label
var faith_label: Label
var believers_label: Label
var build_button: Button
var people_panel: PanelContainer
var people_detail_label: Label
var info_popup: PanelContainer
var info_popup_label: Label
var info_popup_timer: float = 0.0
var build_menu = null
var tutorial_panel: PanelContainer
var tutorial_label: Label
var tutorial_next_btn: Button
var construction_panel: PanelContainer
var construction_label: Label
var construction_bar: ColorRect
var rush_button: Button
var conversion_panel: PanelContainer
var conversion_label: Label
var conversion_bar: ColorRect
var convert_btn: Button
var conversion_rush_btn: Button
var hall_preacher_label: Label   # unused — kept to avoid null refs
var preacher_shelter_panel: PanelContainer
var shelter_preacher_label: Label
var shelter_panel: PanelContainer
var shelter_believer_label: Label
var extra_shelter_panel: PanelContainer = null
var extra_shelter_label: Label = null
var extra_shelter_buildings: Array = []
var current_extra_shelter_idx: int = 0
var temple_panel = null
var pray_go_btn: Button
var pray_selector_row: HBoxContainer
var pray_selector_label: Label
var pray_progress_container: VBoxContainer
var pray_status_label: Label
var pray_bar: ColorRect
var pray_rush_btn: Button
# Extra shelter pray UI (shared, repopulated on each tap)
var extra_pray_go_btn: Button = null
var extra_pray_selector_row: HBoxContainer = null
var extra_pray_selector_label: Label = null
var extra_pray_progress_container: VBoxContainer = null
var extra_pray_selector_count: int = 1

# prayer_sessions: Array of { count, timer, accumulator, nodes, home_pos, shelter_idx, row, bar }
# shelter_idx 0 = Humble Shelter, 1+ = extra shelter slot
var prayer_sessions: Array = []
var prayer_selector_count: int = 1
const PRAYER_TIME := 1800.0

# ── Tutorial ─────────────────────────────────────────────────────────────────
enum TutStep { INTRO, BUILD_TEMPLE, PLACE_TEMPLE, RUSH_PROMPT, TEMPLE_COMPLETE, TAP_SHELTER, TAP_GO_PRAY, CHOOSE_BELIEVERS, COMPLETE, WHEEL_HINT, DONE }
var tut_step := TutStep.INTRO
var tut_popup_dismissed: bool = false
var tutorial_overlay: ColorRect = null
var tutorial_popup: PanelContainer = null
var tutorial_popup_text: Label = null

# ── Resources ────────────────────────────────────────────────────────────────
var preachers_count: int = 0
var preachers_in_shelter: int = 0
var preacher_shelter_built: bool = false
var believer_shelter_count: int = 1   # starts with 1 (the initial shelter)
var believer_capacity: int = 5        # 5 per shelter

# Conversion movement tracking
var converting_node: CharacterBody2D = null   # the believer currently being converted
var preacher_waiting_at_hall: bool = false    # converted but no shelter yet

# ── Spread the Faith ─────────────────────────────────────────────────────────
var spreading: bool = false
var spread_timer: float = 0.0
const SPREAD_TIME := 7200.0  # 2 hours
var spread_sent: int = 0
var spread_selector_count: int = 1
var spreading_nodes: Array = []
var spread_go_btn: Button = null
var spread_selector_row: HBoxContainer = null
var spread_selector_label: Label = null
var spread_progress_container: VBoxContainer = null
var spread_bar: ColorRect = null
var spread_label: Label = null
var spread_rush_btn: Button = null
var spread_result_popup: Control = null
var spread_result_label: Label = null

# ── Crusade ───────────────────────────────────────────────────────────────────
var crusading: bool = false
var crusade_timer: float = 0.0
const CRUSADE_TIME := 7200.0   # 2 hours
var crusade_sent: int = 0
var crusade_selector_count: int = 1
var crusading_nodes: Array = []
var crusade_go_btn: Button = null
var crusade_selector_row: HBoxContainer = null
var crusade_selector_label: Label = null
var crusade_progress_container: VBoxContainer = null
var crusade_bar: ColorRect = null
var crusade_timer_label: Label = null
var crusade_rush_btn: Button = null
var crusade_result_popup = null

# ── Hero Cards ────────────────────────────────────────────────────────────────
var marcus_obtained: bool = false
var hero_deck_chip: PanelContainer = null
var hero_deck_panel = null
var campaign_chip: PanelContainer = null
var return_mission_chip: PanelContainer = null
var generals_quarters: StaticBody2D = null
var generals_quarters_built: bool = false
var marcus_character_node: CharacterBody2D = null
var marcus_leading_crusade: bool = false
var crusade_bring_marcus_btn: Button = null

# ── Timers / state ────────────────────────────────────────────────────────────
var resource_timer    := 0.0
const RESOURCE_INTERVAL := 3.0
var highlight_pulse   := 0.0
var rush_tutorial_arrow: Label = null
var shelter_arrow: PanelContainer = null
var shelter_arrow_label: Label = null
var pray_tutorial_arrow: Label = null
var wheel_tutorial_arrow: PanelContainer = null
var rush_pulse        := 0.0
var placing_building  := false
var placing_type      := ""    # "temple" / "hall_of_devoted" / "preacher_shelter"
var placing_cost      := 0
var placing_road      := false
var placing_road_type := ""    # "road_h" / "road_v" / "road_corner" / "road_t"
var road_rotation_deg := 0     # 0 / 90 / 180 / 270
var road_ghost_sprite: Sprite2D = null
var road_rotate_btn:   Button   = null
var placed_road_tiles: Array = []
var road_controller: RoadPlacementController = null
var camera_controller: CameraController = null
var campaign_navigation_controller: RefCounted = null

# Active construction (one at a time)
var active_construction_node: StaticBody2D = null
var active_construction_type := ""
var active_construction_timer := 0.0
var active_construction_max   := 0.0

const CONSTRUCTION_TIME        := 300.0    # temple: 5 min (prototype speed)
const HALL_CONSTRUCTION_TIME   := 7200.0   # hall: 2 hours
const PREACHER_SHELTER_TIME    := 3600.0   # preacher shelter: 1 hour
const SHELTER_UPGRADE_TIME     := 1800.0   # extra believer shelter: 30 min
const ARMORY_CONSTRUCTION_TIME   := 3600.0   # barracks: 1 hour
const GARRISON_CONSTRUCTION_TIME := 3600.0   # garrison: 1 hour
const TRAINING_TIME              := 1800.0   # soldier training: 30 min
const GENERALS_QUARTERS_TIME     := 3600.0   # general's quarters: 1 hour
const DECORATION_BUILD_TIME      := 60.0     # decorative buildings: 1 min
const MAP_WIDTH                := 3000.0
const MAP_HEIGHT               := 2000.0

# Preacher conversion
var converting        := false
var conversion_timer  := 0.0
const CONVERSION_TIME := 3600.0   # 1 hour per conversion

# ── Positions ────────────────────────────────────────────────────────────────
const SHELTER_POS = Vector2(1500, 1000)

# ── Blocked zones (pos, radius) — can't build here ───────────────────────────
var blocked_zones: Array = []


func _ready():
	_build_world()
	_build_ui()
	campaign_navigation_controller = CampaignNavigationControllerScript.new()
	if GameData.base_camp_state.is_empty():
		_spawn_believers()
	else:
		BaseCampStateScript.restore(self, GameData.base_camp_state)
	_update_tutorial()
	_apply_campaign_results()


func _apply_campaign_results() -> void:
	if GameData.campaign_result_believers <= 0:
		return
	var joined: int = GameData.campaign_result_believers
	var start_count: int = believers_count
	believers_count += joined
	gold            += joined * 15
	BaseCampStateScript.spawn_joined_believers(self, joined, start_count)
	GameData.campaign_result_believers = 0
	GameData.campaign_result_stars     = 0
	_refresh_resource_labels()


func _process(delta):
	# Wheel of Faith daily cooldown
	if not wheel_available:
		wheel_daily_timer += delta
		if wheel_daily_timer >= WheelOfFaithScript.DAILY_COOLDOWN:
			wheel_available = true
			wheel_daily_timer = 0.0
			if wheel_chip_node != null:
				wheel_chip_node.visible = true

	# Shelter arrow follows shelter position on screen (tutorial TAP_SHELTER step)
	if shelter_arrow and shelter_arrow.visible:
		var sp := get_viewport().get_canvas_transform() * SHELTER_POS
		# Position badge ABOVE the shelter, arrow pointing down at it
		shelter_arrow.offset_left   = sp.x - 90
		shelter_arrow.offset_right  = sp.x + 90
		shelter_arrow.offset_top    = sp.y - 145
		shelter_arrow.offset_bottom = sp.y - 105

	# Ghosts follow mouse during placement
	var _world_mouse := get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
	if placing_building and ghost_node:
		ghost_node.position = _world_mouse
	if placing_road and road_ghost_sprite:
		road_ghost_sprite.position = _world_mouse

	# Active construction countdown
	if active_construction_timer > 0.0:
		active_construction_timer -= delta
		if active_construction_timer <= 0.0:
			active_construction_timer = 0.0
			_complete_construction()
		else:
			_update_construction_ui()

	# Preacher conversion countdown
	if converting and conversion_timer > 0.0:
		conversion_timer -= delta
		if conversion_timer <= 0.0:
			conversion_timer = 0.0
			_complete_conversion()
		else:
			_update_conversion_ui()

	# Spread the Faith countdown
	if spreading and spread_timer > 0.0:
		spread_timer -= delta
		_update_spread_ui()
		if spread_timer <= 0.0:
			_complete_spread()

	# Crusade countdown
	if crusading and crusade_timer > 0.0:
		crusade_timer -= delta
		if crusade_timer <= 0.0:
			crusade_timer = 0.0
			_complete_crusade()
		else:
			_update_crusade_ui()

	# Soldier training countdown
	if training and training_timer > 0.0:
		training_timer -= delta
		if training_timer <= 0.0:
			training_timer = 0.0
			_complete_training()
		else:
			_update_training_ui()

	# Prayer countdown — iterate all active sessions
	if prayer_sessions.size() > 0:
		for i in range(prayer_sessions.size() - 1, -1, -1):
			var sess: Dictionary = prayer_sessions[i]
			sess.timer -= delta
			sess.accumulator += delta
			while sess.accumulator >= 60.0:
				faith += sess.count
				sess.accumulator -= 60.0
				_refresh_resource_labels()
			if is_instance_valid(sess.bar):
				sess.bar.anchor_right = sess.accumulator / 60.0
			if sess.timer <= 0.0:
				_complete_prayer_session(i)
		if shelter_panel.visible:
			_update_prayer_ui()
		if extra_shelter_panel != null and extra_shelter_panel.visible:
			_update_extra_prayer_ui()
		if temple_panel.visible:
			_refresh_temple_panel()

	# Info popup auto-hide
	if info_popup_timer > 0.0:
		info_popup_timer -= delta
		if info_popup_timer <= 0.0:
			info_popup.visible = false

	resource_timer += delta
	if resource_timer >= RESOURCE_INTERVAL:
		resource_timer = 0.0
		_tick_resources()
	_refresh_resource_labels()
	_pulse_build_button(delta)


# ── Resource tick ─────────────────────────────────────────────────────────────
func _tick_resources():
	gold += believers_count          # each believer pays 1 gold/tick
	# Faith comes only from prayer (see _on_pray_confirm_pressed)


# ── World ─────────────────────────────────────────────────────────────────────
func _build_world():
	world = Node2D.new()
	add_child(world)

	# Map background — tiled grass texture
	var grass := TextureRect.new()
	grass.texture      = load("res://assets/environment/Background0.png")
	grass.stretch_mode = TextureRect.STRETCH_TILE
	grass.size         = Vector2(MAP_WIDTH, MAP_HEIGHT)
	grass.mouse_filter = Control.MOUSE_FILTER_IGNORE   # don't block Area2D clicks
	world.add_child(grass)

	# Camera — centered on starting area, limited to map bounds
	camera = Camera2D.new()
	camera.position = SHELTER_POS
	camera.limit_left   = 0
	camera.limit_top    = 0
	camera.limit_right  = int(MAP_WIDTH)
	camera.limit_bottom = int(MAP_HEIGHT)
	add_child(camera)

	camera_controller = CameraControllerScript.new()
	camera_controller.setup(camera)

	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	# Scattered trees (avoid center area)
	_plant_trees(rng)


	# Humble Shelter — interactive so you can tap it for capacity info
	shelter = _make_building("shelter", SHELTER_POS, "Humble Shelter", true)
	shelter.tapped.connect(_on_believer_shelter_tapped)
	blocked_zones.append({"pos": SHELTER_POS, "radius": 85.0})


func _plant_trees(rng: RandomNumberGenerator):
	var placed: Array = []
	var attempts := 0
	# Scatter trees (mix of Comp15 and Comp16)
	while placed.size() < 55 and attempts < 2000:
		attempts += 1
		var tp := Vector2(rng.randf_range(80, MAP_WIDTH - 80), rng.randf_range(80, MAP_HEIGHT - 80))
		if tp.distance_to(SHELTER_POS) < 320:
			continue
		var too_close := false
		for p in placed:
			if tp.distance_to(p) < 110:
				too_close = true
				break
		if too_close:
			continue
		placed.append(tp)
		_place_tree_sprite(tp, rng)
		blocked_zones.append({"pos": tp, "radius": 70.0})
	# Scatter rocks (Comp17)
	var rock_placed: Array = []
	attempts = 0
	while rock_placed.size() < 18 and attempts < 1000:
		attempts += 1
		var rp := Vector2(rng.randf_range(80, MAP_WIDTH - 80), rng.randf_range(80, MAP_HEIGHT - 80))
		if rp.distance_to(SHELTER_POS) < 300:
			continue
		var too_close := false
		for p in placed:
			if rp.distance_to(p) < 80:
				too_close = true
				break
		for p in rock_placed:
			if rp.distance_to(p) < 90:
				too_close = true
				break
		if too_close:
			continue
		rock_placed.append(rp)
		_place_rock_sprite(rp, rng)
		blocked_zones.append({"pos": rp, "radius": 50.0})


func _place_tree_sprite(pos: Vector2, rng: RandomNumberGenerator):
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/environment/Comp15.png" if rng.randi() % 2 == 0 else "res://assets/environment/Comp16.png")
	var sc: float = rng.randf_range(0.26, 0.36)
	spr.scale = Vector2(sc, sc)
	spr.flip_h = rng.randi() % 2 == 1
	spr.position = pos
	world.add_child(spr)


func _place_rock_sprite(pos: Vector2, rng: RandomNumberGenerator):
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/environment/Comp17.png")
	var sc: float = rng.randf_range(0.18, 0.26)
	spr.scale = Vector2(sc, sc)
	spr.flip_h = rng.randi() % 2 == 1
	spr.position = pos
	world.add_child(spr)


func _road_corner(from_pos: Vector2, to_pos: Vector2) -> Vector2:
	return Vector2(from_pos.x, to_pos.y)


func _walk_via_road(node: CharacterBody2D, from_pos: Vector2, to_pos: Vector2, on_arrive: Callable):
	# Mirror RoadSegmentDrawer._ready() exactly so characters follow the visual road
	if to_pos.y < from_pos.y - 20.0:
		# Destination is above — exit south first, then horizontal, then north (same as visual road)
		var road_y := from_pos.y + 60.0
		var p1 := Vector2(from_pos.x, road_y)
		var p2 := Vector2(to_pos.x, road_y)
		node.walk_to(p1)
		node.reached_forced_target.connect(func():
			node.walk_to(p2)
			node.reached_forced_target.connect(func():
				node.walk_to(to_pos)
				node.reached_forced_target.connect(on_arrive, CONNECT_ONE_SHOT)
			, CONNECT_ONE_SHOT)
		, CONNECT_ONE_SHOT)
	else:
		# Destination at same level or below — vertical-first L
		var corner := Vector2(from_pos.x, to_pos.y)
		if corner.distance_to(to_pos) < 4.0 or corner.distance_to(from_pos) < 4.0:
			node.walk_to(to_pos)
			node.reached_forced_target.connect(on_arrive, CONNECT_ONE_SHOT)
		else:
			node.walk_to(corner)
			node.reached_forced_target.connect(func():
				node.walk_to(to_pos)
				node.reached_forced_target.connect(on_arrive, CONNECT_ONE_SHOT)
			, CONNECT_ONE_SHOT)


func _show_road_hint(msg: String):
	if tutorial_label == null:
		return
	tutorial_label.text = msg
	get_tree().create_timer(5.0).timeout.connect(func():
		if tutorial_label and tutorial_label.text == msg:
			tutorial_label.text = "")



func _make_building(type: String, pos: Vector2, label: String, interactive: bool) -> StaticBody2D:
	var scene: PackedScene = BUILDING_SCENES.get(type, BUILDING_SCENES["shelter"])
	var b: StaticBody2D = scene.instantiate()
	b.building_type  = type
	b.building_label = label
	b.is_interactive = interactive
	b.position       = pos
	world.add_child(b)

	return b


# ── Believers ────────────────────────────────────────────────────────────────
func _spawn_believers():
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(5):
		var b: CharacterBody2D = load("res://scenes/believer.tscn").instantiate()
		var offset := Vector2(rng.randf_range(-35, 35), rng.randf_range(-8, 8))
		world.add_child(b)
		b.setup(SHELTER_POS + Vector2(0, 80) + offset, i)
		believers.append(b)


# ── UI ────────────────────────────────────────────────────────────────────────
func _build_ui():
	var ui := CanvasLayer.new()
	ui.layer = 10
	add_child(ui)

	_build_top_bar(ui)
	_build_build_button(ui)
	_build_build_menu(ui)
	road_controller = RoadPlacementControllerScript.new()
	road_rotate_btn = road_controller.setup_rotate_button(ui, _on_road_rotate)
	_build_construction_panel(ui)
	_build_conversion_panel(ui)
	_build_training_panel(ui)
	_build_preacher_shelter_panel(ui)
	_build_garrison_panel(ui)
	_build_shelter_panel(ui)
	_build_extra_shelter_panel(ui)
	_build_temple_panel(ui)
	_build_tutorial_panel(ui)
	_build_info_popup(ui)
	_build_wheel_popup(ui)
	_build_crusade_result_popup(ui)
	_build_hero_deck_panel(ui)


func _build_top_bar(ui: CanvasLayer):
	var top_bar: Dictionary = TopBarFactoryScript.build(
		ui,
		wheel_available,
		GameData.mission_active,
		_on_people_chip_input,
		_on_wheel_chip_input,
		_on_hero_deck_chip_input,
		_on_campaign_chip_input,
		_on_return_mission_input
	)
	believers_label = top_bar["believers_label"]
	faith_label = top_bar["faith_label"]
	gold_label = top_bar["gold_label"]
	wheel_chip_node = top_bar["wheel_chip"]
	hero_deck_chip = top_bar["hero_deck_chip"]
	campaign_chip = top_bar["campaign_chip"]
	return_mission_chip = top_bar["return_mission_chip"]

	_build_people_panel(ui)

	_refresh_resource_labels()


func _build_people_panel(ui: CanvasLayer):
	people_panel = PanelContainer.new()
	people_panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	people_panel.anchor_left   = 0.0
	people_panel.anchor_right  = 0.0
	people_panel.anchor_top    = 0.0
	people_panel.anchor_bottom = 0.0
	people_panel.offset_left   = 6
	people_panel.offset_top    = 58
	people_panel.offset_right  = 220
	people_panel.offset_bottom = 130
	people_panel.visible = false
	ui.add_child(people_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	people_panel.add_child(vbox)

	var title := Label.new()
	title.layout_direction = Control.LAYOUT_DIRECTION_LTR
	title.text = "Your People"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.40))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	people_detail_label = Label.new()
	people_detail_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	people_detail_label.add_theme_font_size_override("font_size", 13)
	people_detail_label.add_theme_color_override("font_color", Color(0.90, 0.90, 0.90))
	vbox.add_child(people_detail_label)


func _on_people_chip_input(event: InputEvent):
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	people_panel.visible = not people_panel.visible
	if people_panel.visible:
		_refresh_people_panel()


func _refresh_people_panel():
	people_detail_label.text = (
		"Believers:   %d\n" % believers_count +
		"Preachers:  %d\n" % preachers_count +
		"Soldiers:    %d" % soldiers_count
	)


func _build_info_popup(ui: CanvasLayer):
	info_popup = PanelContainer.new()
	info_popup.layout_direction = Control.LAYOUT_DIRECTION_LTR
	info_popup.visible = false
	ui.add_child(info_popup)

	info_popup_label = Label.new()
	info_popup_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	info_popup_label.add_theme_font_size_override("font_size", 15)
	info_popup_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.75))
	info_popup.add_child(info_popup_label)


func _show_building_info(building: StaticBody2D, text: String):
	info_popup_label.text = text
	# canvas_transform maps world coords → screen coords (accounts for camera)
	var screen_pos := get_viewport().get_canvas_transform() * building.global_position
	info_popup.position = screen_pos + Vector2(-50, -110)
	info_popup.visible = true
	info_popup_timer = 3.0


func _on_believer_shelter_tapped():
	conversion_panel.visible = false
	training_panel.visible = false
	preacher_shelter_panel.visible = false
	garrison_panel.visible = false
	if extra_shelter_panel:
		extra_shelter_panel.visible = false
	shelter_panel.visible = not shelter_panel.visible
	if shelter_panel.visible:
		shelter_believer_label.text = "%d / 5" % mini(believers_count, 5)
		if _has_session(0):
			_update_prayer_ui()
		else:
			_reset_prayer_ui()
		if tut_step == TutStep.TAP_SHELTER:
			tut_step = TutStep.TAP_GO_PRAY
			tut_popup_dismissed = false
			_update_tutorial()


func _on_preacher_shelter_tapped():
	conversion_panel.visible = false
	training_panel.visible = false
	garrison_panel.visible = false
	shelter_panel.visible = false
	if extra_shelter_panel:
		extra_shelter_panel.visible = false
	preacher_shelter_panel.visible = not preacher_shelter_panel.visible
	if preacher_shelter_panel.visible:
		_refresh_preacher_label()


func _build_build_button(ui: CanvasLayer):
	build_button = Button.new()
	build_button.text = "Build"
	build_button.custom_minimum_size = Vector2(120, 44)
	build_button.add_theme_font_size_override("font_size", 18)
	build_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	# Anchor to bottom-right corner so it's always in the corner regardless of RTL
	build_button.anchor_left   = 1.0
	build_button.anchor_right  = 1.0
	build_button.anchor_top    = 1.0
	build_button.anchor_bottom = 1.0
	build_button.offset_left   = -130
	build_button.offset_top    = -54
	build_button.offset_right  = 0
	build_button.offset_bottom = 0
	build_button.pressed.connect(_on_build_pressed)
	ui.add_child(build_button)


# ── Road placement ────────────────────────────────────────────────────────────

func _on_road_rotate():
	if road_controller != null:
		road_controller.rotate()
		road_rotation_deg = road_controller.rotation_deg
		road_ghost_sprite = road_controller.ghost_sprite

func _start_road_placement(type: String):
	build_menu.hide_menu()
	var mouse_pos := get_viewport().get_canvas_transform().affine_inverse() \
		* get_viewport().get_mouse_position()
	road_controller.start(type, world, mouse_pos)
	_sync_road_controller_state()

func _cancel_road_placement():
	if road_controller != null:
		road_controller.cancel()
	_sync_road_controller_state()

func _place_road_tile(pos: Vector2):
	if road_controller == null:
		return
	road_controller.place(world, pos)
	_sync_road_controller_state()



func _sync_road_controller_state() -> void:
	if road_controller == null:
		return
	placing_road = road_controller.active
	placing_road_type = road_controller.road_type
	road_rotation_deg = road_controller.rotation_deg
	road_ghost_sprite = road_controller.ghost_sprite
	placed_road_tiles = road_controller.placed_tiles


func _build_build_menu(ui: CanvasLayer):
	build_menu = BUILD_MENU_SCENE.instantiate()
	ui.add_child(build_menu)
	build_menu.build_requested.connect(_on_build_menu_build_requested)
	build_menu.road_requested.connect(_on_build_menu_road_requested)


func _build_conversion_panel(ui: CanvasLayer):
	conversion_panel = BuildingPanelFactoryScript.make_panel(ui, Color(0.35, 0.55, 1.00), "Hall of the Devoted")

	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(conversion_panel)

	# Status + progress
	conversion_label = Label.new()
	conversion_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	conversion_label.text = "Ready to convert"
	conversion_label.add_theme_font_size_override("font_size", 13)
	conversion_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	body.add_child(conversion_label)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.10, 0.08, 0.18)
	bar_bg.custom_minimum_size = Vector2(0, 8)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(bar_bg)
	conversion_bar = ColorRect.new()
	conversion_bar.color = Color(0.35, 0.55, 1.00)
	conversion_bar.anchor_top = 0.0; conversion_bar.anchor_bottom = 1.0
	conversion_bar.anchor_left = 0.0; conversion_bar.anchor_right = 0.0
	bar_bg.add_child(conversion_bar)

	# Action buttons
	var btn_row := HBoxContainer.new()
	btn_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	btn_row.add_theme_constant_override("separation", 8)
	body.add_child(btn_row)

	convert_btn = Button.new()
	convert_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	convert_btn.text = "Convert Believer  (1 hr)"
	convert_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	convert_btn.pressed.connect(_on_convert_pressed)
	BuildingPanelFactoryScript.style_action_btn(convert_btn, Color(0.35, 0.55, 1.00))
	btn_row.add_child(convert_btn)

	conversion_rush_btn = Button.new()
	conversion_rush_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	conversion_rush_btn.text = "⚡ -10m"
	conversion_rush_btn.custom_minimum_size = Vector2(70, 0)
	conversion_rush_btn.visible = false
	conversion_rush_btn.pressed.connect(_on_conversion_rush_pressed)
	BuildingPanelFactoryScript.style_action_btn(conversion_rush_btn, Color(0.85, 0.65, 0.10))
	btn_row.add_child(conversion_rush_btn)

	BuildingPanelFactoryScript.panel_sep(body, Color(0.35, 0.55, 1.00))

	# Upgrade button (locked)
	var upg := Button.new()
	upg.layout_direction = Control.LAYOUT_DIRECTION_LTR
	upg.text = "⬆  Upgrade Building   (Coming Soon)"
	upg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upg.disabled = true
	BuildingPanelFactoryScript.style_action_btn(upg, Color(0.50, 0.48, 0.44))
	body.add_child(upg)


func _build_training_panel(ui: CanvasLayer):
	training_panel = BuildingPanelFactoryScript.make_panel(ui, Color(0.85, 0.28, 0.18), "Barracks")

	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(training_panel)

	# Status + progress
	training_label = Label.new()
	training_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	training_label.text = "Ready to train"
	training_label.add_theme_font_size_override("font_size", 13)
	training_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	body.add_child(training_label)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.10, 0.08, 0.18)
	bar_bg.custom_minimum_size = Vector2(0, 8)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(bar_bg)
	training_bar = ColorRect.new()
	training_bar.color = Color(0.85, 0.28, 0.18)
	training_bar.anchor_top = 0.0; training_bar.anchor_bottom = 1.0
	training_bar.anchor_left = 0.0; training_bar.anchor_right = 0.0
	bar_bg.add_child(training_bar)

	# Action buttons
	var btn_row := HBoxContainer.new()
	btn_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	btn_row.add_theme_constant_override("separation", 8)
	body.add_child(btn_row)

	train_btn = Button.new()
	train_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	train_btn.text = "Train Soldier  (30 min)"
	train_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	train_btn.pressed.connect(_on_train_pressed)
	BuildingPanelFactoryScript.style_action_btn(train_btn, Color(0.85, 0.28, 0.18))
	btn_row.add_child(train_btn)

	training_rush_btn = Button.new()
	training_rush_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	training_rush_btn.text = "⚡ -10m"
	training_rush_btn.custom_minimum_size = Vector2(70, 0)
	training_rush_btn.visible = false
	training_rush_btn.pressed.connect(_on_training_rush_pressed)
	BuildingPanelFactoryScript.style_action_btn(training_rush_btn, Color(0.85, 0.65, 0.10))
	btn_row.add_child(training_rush_btn)

	BuildingPanelFactoryScript.panel_sep(body, Color(0.85, 0.28, 0.18))

	# Upgrade button (locked)
	var upg := Button.new()
	upg.layout_direction = Control.LAYOUT_DIRECTION_LTR
	upg.text = "⬆  Upgrade Building   (Coming Soon)"
	upg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upg.disabled = true
	BuildingPanelFactoryScript.style_action_btn(upg, Color(0.50, 0.48, 0.44))
	body.add_child(upg)


func _build_preacher_shelter_panel(ui: CanvasLayer):
	preacher_shelter_panel = BuildingPanelFactoryScript.make_panel(ui, Color(0.30, 0.75, 0.72), "Preacher Shelter")
	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(preacher_shelter_panel)

	shelter_preacher_label = BuildingPanelFactoryScript.count_row(body, "Preachers", Color(0.30, 0.82, 0.75))

	BuildingPanelFactoryScript.panel_sep(body, Color(0.30, 0.75, 0.72))

	# ── Go button ──
	spread_go_btn = Button.new()
	spread_go_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	spread_go_btn.text = "✉  Spread the Faith   (2 hr)"
	spread_go_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	BuildingPanelFactoryScript.style_action_btn(spread_go_btn, Color(0.30, 0.75, 0.72))
	spread_go_btn.pressed.connect(_on_spread_pressed)
	body.add_child(spread_go_btn)

	# ── Selector row (hidden until Go tapped) ──
	spread_selector_row = HBoxContainer.new()
	spread_selector_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	spread_selector_row.visible = false
	body.add_child(spread_selector_row)

	var minus_btn := Button.new()
	minus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	minus_btn.text = "−"
	minus_btn.custom_minimum_size = Vector2(30, 0)
	minus_btn.pressed.connect(func():
		spread_selector_count = max(1, spread_selector_count - 1)
		_update_spread_selector_label())
	spread_selector_row.add_child(minus_btn)

	spread_selector_label = Label.new()
	spread_selector_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	spread_selector_label.text_direction = Control.TEXT_DIRECTION_LTR
	spread_selector_label.text = "1 preacher"
	spread_selector_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spread_selector_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spread_selector_label.add_theme_font_size_override("font_size", 13)
	spread_selector_row.add_child(spread_selector_label)

	var plus_btn := Button.new()
	plus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	plus_btn.text = "+"
	plus_btn.custom_minimum_size = Vector2(30, 0)
	plus_btn.pressed.connect(func():
		spread_selector_count = min(preachers_in_shelter, spread_selector_count + 1)
		_update_spread_selector_label())
	spread_selector_row.add_child(plus_btn)

	var confirm_btn := Button.new()
	confirm_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	confirm_btn.text = "Send →"
	BuildingPanelFactoryScript.style_action_btn(confirm_btn, Color(0.30, 0.75, 0.72))
	confirm_btn.pressed.connect(_on_spread_confirm_pressed)
	spread_selector_row.add_child(confirm_btn)

	# ── Progress area (hidden until mission started) ──
	spread_progress_container = VBoxContainer.new()
	spread_progress_container.layout_direction = Control.LAYOUT_DIRECTION_LTR
	spread_progress_container.visible = false
	body.add_child(spread_progress_container)

	spread_label = Label.new()
	spread_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	spread_label.text = "Spreading the faith..."
	spread_label.add_theme_font_size_override("font_size", 12)
	spread_label.add_theme_color_override("font_color", Color(0.30, 0.90, 0.80))
	spread_progress_container.add_child(spread_label)

	# Progress bar background + fill
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.10, 0.08, 0.16)
	bar_bg.custom_minimum_size = Vector2(0, 8)
	spread_progress_container.add_child(bar_bg)

	spread_bar = ColorRect.new()
	spread_bar.color = Color(0.30, 0.82, 0.75)
	spread_bar.anchor_top    = 0.0
	spread_bar.anchor_bottom = 1.0
	spread_bar.anchor_left   = 0.0
	spread_bar.anchor_right  = 0.0
	bar_bg.add_child(spread_bar)

	spread_rush_btn = Button.new()
	spread_rush_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	spread_rush_btn.text = "⚡ Rush  (1 Faith = -10 min)"
	spread_rush_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	BuildingPanelFactoryScript.style_action_btn(spread_rush_btn, Color(0.72, 0.55, 1.00))
	spread_rush_btn.pressed.connect(_on_spread_rush_pressed)
	spread_progress_container.add_child(spread_rush_btn)

	BuildingPanelFactoryScript.panel_sep(body, Color(0.30, 0.75, 0.72))

	var upg := Button.new()
	upg.layout_direction = Control.LAYOUT_DIRECTION_LTR
	upg.text = "⬆  Upgrade Building   (Coming Soon)"
	upg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upg.disabled = true
	BuildingPanelFactoryScript.style_action_btn(upg, Color(0.50, 0.48, 0.44))
	body.add_child(upg)

	# ── Mission result popup (CanvasLayer level) ──
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	ui.add_child(overlay)
	spread_result_popup = overlay

	var result_panel := PanelContainer.new()
	result_panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	var rps := StyleBoxFlat.new()
	rps.bg_color     = Color(0.08, 0.06, 0.14)
	rps.border_color = Color(0.30, 0.80, 0.75)
	rps.set_border_width_all(2)
	rps.set_corner_radius_all(12)
	rps.content_margin_left = 28; rps.content_margin_right  = 28
	rps.content_margin_top  = 22; rps.content_margin_bottom = 22
	result_panel.add_theme_stylebox_override("panel", rps)
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.offset_left = -220; result_panel.offset_right  = 220
	result_panel.offset_top  = -110; result_panel.offset_bottom = 110
	overlay.add_child(result_panel)

	var vb := VBoxContainer.new()
	vb.layout_direction = Control.LAYOUT_DIRECTION_LTR
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 14)
	result_panel.add_child(vb)

	var title := Label.new()
	title.layout_direction = Control.LAYOUT_DIRECTION_LTR
	title.text = "✉  Mission Complete!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color(0.30, 0.90, 0.80))
	vb.add_child(title)

	spread_result_label = Label.new()
	spread_result_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	spread_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spread_result_label.add_theme_font_size_override("font_size", 14)
	spread_result_label.add_theme_color_override("font_color", Color(0.92, 0.90, 0.98))
	vb.add_child(spread_result_label)

	var ok_btn := Button.new()
	ok_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	ok_btn.text = "Praise be!"
	ok_btn.pressed.connect(func(): overlay.visible = false)
	BuildingPanelFactoryScript.style_action_btn(ok_btn, Color(0.30, 0.75, 0.72))
	vb.add_child(ok_btn)


func _build_shelter_panel(ui: CanvasLayer):
	shelter_panel = BuildingPanelFactoryScript.make_panel(ui, Color(0.85, 0.55, 0.18), "Humble Shelter")
	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(shelter_panel)

	shelter_believer_label = BuildingPanelFactoryScript.count_row(body, "Believers", Color(0.92, 0.75, 0.38))

	BuildingPanelFactoryScript.panel_sep(body, Color(0.85, 0.55, 0.18))

	# Tutorial hint — shown only during TAP_GO_PRAY step
	pray_tutorial_arrow = Label.new()
	pray_tutorial_arrow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	pray_tutorial_arrow.text = "↓  Tap Go Pray!"
	pray_tutorial_arrow.add_theme_font_size_override("font_size", 14)
	pray_tutorial_arrow.add_theme_color_override("font_color", Color(1.0, 0.18, 0.18))
	pray_tutorial_arrow.visible = false
	body.add_child(pray_tutorial_arrow)

	# Go Pray button
	pray_go_btn = Button.new()
	pray_go_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	pray_go_btn.text = "🙏  Go Pray  (30 min)"
	pray_go_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pray_go_btn.pressed.connect(_on_go_pray_pressed)
	BuildingPanelFactoryScript.style_action_btn(pray_go_btn, Color(0.55, 0.35, 0.82))
	body.add_child(pray_go_btn)

	# Selector row (hidden initially)
	pray_selector_row = HBoxContainer.new()
	pray_selector_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	pray_selector_row.add_theme_constant_override("separation", 4)
	pray_selector_row.visible = false
	body.add_child(pray_selector_row)

	var minus_btn := Button.new()
	minus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	minus_btn.text = "−"
	minus_btn.custom_minimum_size = Vector2(30, 0)
	minus_btn.pressed.connect(func():
		prayer_selector_count = max(1, prayer_selector_count - 1)
		_update_pray_selector_label()
	)
	BuildingPanelFactoryScript.style_action_btn(minus_btn, Color(0.55, 0.35, 0.82))
	pray_selector_row.add_child(minus_btn)

	pray_selector_label = Label.new()
	pray_selector_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	pray_selector_label.text_direction = Control.TEXT_DIRECTION_LTR
	pray_selector_label.text = "1 believer"
	pray_selector_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pray_selector_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pray_selector_label.add_theme_font_size_override("font_size", 13)
	pray_selector_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	pray_selector_row.add_child(pray_selector_label)

	var plus_btn := Button.new()
	plus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	plus_btn.text = "+"
	plus_btn.custom_minimum_size = Vector2(30, 0)
	plus_btn.pressed.connect(func():
		prayer_selector_count = min(believers_count, prayer_selector_count + 1)
		_update_pray_selector_label()
	)
	BuildingPanelFactoryScript.style_action_btn(plus_btn, Color(0.55, 0.35, 0.82))
	pray_selector_row.add_child(plus_btn)

	var confirm_btn := Button.new()
	confirm_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	confirm_btn.text = "Send to Pray"
	confirm_btn.pressed.connect(_on_pray_confirm_pressed)
	BuildingPanelFactoryScript.style_action_btn(confirm_btn, Color(0.55, 0.35, 0.82))
	pray_selector_row.add_child(confirm_btn)

	var cancel_btn := Button.new()
	cancel_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(_on_pray_cancel_pressed)
	BuildingPanelFactoryScript.style_action_btn(cancel_btn, Color(0.50, 0.48, 0.44))
	pray_selector_row.add_child(cancel_btn)

	# Progress container (hidden initially)
	pray_progress_container = VBoxContainer.new()
	pray_progress_container.layout_direction = Control.LAYOUT_DIRECTION_LTR
	pray_progress_container.add_theme_constant_override("separation", 6)
	pray_progress_container.visible = false
	body.add_child(pray_progress_container)

	pray_status_label = Label.new()
	pray_status_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	pray_status_label.text = "Praying: 1 believer — 30:00"
	pray_status_label.add_theme_font_size_override("font_size", 13)
	pray_status_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	pray_progress_container.add_child(pray_status_label)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.10, 0.08, 0.18)
	bar_bg.custom_minimum_size = Vector2(0, 8)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pray_progress_container.add_child(bar_bg)
	pray_bar = ColorRect.new()
	pray_bar.color = Color(0.55, 0.35, 0.82)
	pray_bar.anchor_top = 0.0; pray_bar.anchor_bottom = 1.0
	pray_bar.anchor_left = 0.0; pray_bar.anchor_right = 0.0
	bar_bg.add_child(pray_bar)

	pray_rush_btn = Button.new()
	pray_rush_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	pray_rush_btn.text = "⚡ -10m"
	pray_rush_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pray_rush_btn.pressed.connect(_on_pray_rush_pressed)
	BuildingPanelFactoryScript.style_action_btn(pray_rush_btn, Color(0.85, 0.65, 0.10))
	pray_progress_container.add_child(pray_rush_btn)

	BuildingPanelFactoryScript.panel_sep(body, Color(0.85, 0.55, 0.18))

	var upg := Button.new()
	upg.layout_direction = Control.LAYOUT_DIRECTION_LTR
	upg.text = "⬆  Upgrade Building   (Coming Soon)"
	upg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upg.disabled = true
	BuildingPanelFactoryScript.style_action_btn(upg, Color(0.50, 0.48, 0.44))
	body.add_child(upg)


func _build_extra_shelter_panel(ui: CanvasLayer):
	extra_shelter_panel = BuildingPanelFactoryScript.make_panel(ui, Color(0.85, 0.55, 0.18), "Believer Shelter")
	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(extra_shelter_panel)

	extra_shelter_label = BuildingPanelFactoryScript.count_row(body, "Believers", Color(0.92, 0.75, 0.38))

	BuildingPanelFactoryScript.panel_sep(body, Color(0.85, 0.55, 0.18))

	# Go Pray button
	extra_pray_go_btn = Button.new()
	extra_pray_go_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	extra_pray_go_btn.text = "🙏  Go Pray  (30 min)"
	extra_pray_go_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	extra_pray_go_btn.pressed.connect(_on_extra_go_pray_pressed)
	BuildingPanelFactoryScript.style_action_btn(extra_pray_go_btn, Color(0.55, 0.35, 0.82))
	body.add_child(extra_pray_go_btn)

	# Selector row
	extra_pray_selector_row = HBoxContainer.new()
	extra_pray_selector_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	extra_pray_selector_row.add_theme_constant_override("separation", 4)
	extra_pray_selector_row.visible = false
	body.add_child(extra_pray_selector_row)

	var minus_btn := Button.new()
	minus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	minus_btn.text = "−"
	minus_btn.custom_minimum_size = Vector2(30, 0)
	minus_btn.pressed.connect(func():
		extra_pray_selector_count = max(1, extra_pray_selector_count - 1)
		_update_extra_pray_selector_label()
	)
	BuildingPanelFactoryScript.style_action_btn(minus_btn, Color(0.55, 0.35, 0.82))
	extra_pray_selector_row.add_child(minus_btn)

	extra_pray_selector_label = Label.new()
	extra_pray_selector_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	extra_pray_selector_label.text_direction = Control.TEXT_DIRECTION_LTR
	extra_pray_selector_label.text = "1 believer"
	extra_pray_selector_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	extra_pray_selector_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	extra_pray_selector_label.add_theme_font_size_override("font_size", 13)
	extra_pray_selector_row.add_child(extra_pray_selector_label)

	var plus_btn := Button.new()
	plus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	plus_btn.text = "+"
	plus_btn.custom_minimum_size = Vector2(30, 0)
	plus_btn.pressed.connect(func():
		var in_shelter: int = clamp(believers_count - current_extra_shelter_idx * 5, 0, 5)
		var temple_slots: int = 5 - _praying_count()
		extra_pray_selector_count = min(extra_pray_selector_count + 1, mini(in_shelter, temple_slots))
		_update_extra_pray_selector_label()
	)
	BuildingPanelFactoryScript.style_action_btn(plus_btn, Color(0.55, 0.35, 0.82))
	extra_pray_selector_row.add_child(plus_btn)

	var confirm_btn := Button.new()
	confirm_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	confirm_btn.text = "Send to Pray"
	confirm_btn.pressed.connect(_on_extra_pray_confirm_pressed)
	BuildingPanelFactoryScript.style_action_btn(confirm_btn, Color(0.55, 0.35, 0.82))
	extra_pray_selector_row.add_child(confirm_btn)

	var cancel_btn := Button.new()
	cancel_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(func():
		extra_pray_selector_row.visible = false
		extra_pray_go_btn.visible = true
	)
	BuildingPanelFactoryScript.style_action_btn(cancel_btn, Color(0.50, 0.48, 0.44))
	extra_pray_selector_row.add_child(cancel_btn)

	# Progress container (shown during active session from this shelter)
	extra_pray_progress_container = VBoxContainer.new()
	extra_pray_progress_container.layout_direction = Control.LAYOUT_DIRECTION_LTR
	extra_pray_progress_container.add_theme_constant_override("separation", 4)
	extra_pray_progress_container.visible = false
	body.add_child(extra_pray_progress_container)

	var prog_lbl := Label.new()
	prog_lbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	prog_lbl.text_direction = Control.TEXT_DIRECTION_LTR
	prog_lbl.text = "Praying..."
	prog_lbl.add_theme_font_size_override("font_size", 13)
	prog_lbl.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	extra_pray_progress_container.add_child(prog_lbl)

	BuildingPanelFactoryScript.panel_sep(body, Color(0.85, 0.55, 0.18))

	var upg := Button.new()
	upg.layout_direction = Control.LAYOUT_DIRECTION_LTR
	upg.text = "⬆  Upgrade Building   (Coming Soon)"
	upg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upg.disabled = true
	BuildingPanelFactoryScript.style_action_btn(upg, Color(0.50, 0.48, 0.44))
	body.add_child(upg)


func _refresh_extra_shelter_panel():
	var filled: int = clamp(believers_count - current_extra_shelter_idx * 5, 0, 5)
	extra_shelter_label.text = "%d / 5" % filled
	# Restore correct pray button / progress state for this shelter
	var has_sess := _has_session(current_extra_shelter_idx)
	extra_pray_go_btn.visible = not has_sess
	extra_pray_go_btn.disabled = filled <= 0 or temple == null or _praying_count() >= 5
	extra_pray_selector_row.visible = false
	extra_pray_progress_container.visible = has_sess
	if has_sess:
		_update_extra_prayer_ui()

func _on_extra_go_pray_pressed():
	var in_shelter: int = clamp(believers_count - current_extra_shelter_idx * 5, 0, 5)
	if _has_session(current_extra_shelter_idx) or in_shelter <= 0 or temple == null or _praying_count() >= 5:
		return
	var temple_slots: int = 5 - _praying_count()
	extra_pray_selector_count = mini(1, mini(in_shelter, temple_slots))
	_update_extra_pray_selector_label()
	extra_pray_go_btn.visible = false
	extra_pray_selector_row.visible = true

func _update_extra_pray_selector_label():
	var s := "s" if extra_pray_selector_count > 1 else ""
	extra_pray_selector_label.text = "%d believer%s" % [extra_pray_selector_count, s]

func _on_extra_pray_confirm_pressed():
	var shelter_pos: Vector2
	if current_extra_shelter_idx - 1 < extra_shelter_buildings.size():
		shelter_pos = extra_shelter_buildings[current_extra_shelter_idx - 1].position
	else:
		return
	_start_prayer_session(current_extra_shelter_idx, shelter_pos + Vector2(0, 80), extra_pray_selector_count,
		extra_pray_selector_row, extra_pray_progress_container, extra_pray_go_btn)


func _praying_count() -> int:
	var total := 0
	for s in prayer_sessions:
		total += s.count
	return total

func _has_session(shelter_idx: int) -> bool:
	for s in prayer_sessions:
		if s.shelter_idx == shelter_idx:
			return true
	return false

func _on_go_pray_pressed():
	var available_in_shelter := mini(believers_count, 5)
	if _has_session(0) or available_in_shelter <= 0 or temple == null or _praying_count() >= 5:
		return
	prayer_selector_count = mini(1, available_in_shelter)
	_update_pray_selector_label()
	pray_go_btn.visible = false
	pray_selector_row.visible = true
	if tut_step == TutStep.TAP_GO_PRAY:
		tut_step = TutStep.CHOOSE_BELIEVERS
		tut_popup_dismissed = true
		_update_tutorial()


func _on_pray_cancel_pressed():
	pray_selector_row.visible = false
	pray_go_btn.visible = true


func _on_pray_confirm_pressed():
	_start_prayer_session(0, SHELTER_POS + Vector2(0, 80), prayer_selector_count,
		pray_selector_row, pray_progress_container, pray_go_btn)
	if tut_step == TutStep.CHOOSE_BELIEVERS:
		tut_step = TutStep.COMPLETE
		tut_popup_dismissed = false
		_update_tutorial()

func _start_prayer_session(shelter_idx: int, home_pos: Vector2, wanted: int,
		selector_row: HBoxContainer, progress_container: VBoxContainer, go_btn: Button):
	if temple == null or wanted <= 0 or _praying_count() + wanted > 5:
		return
	# Walk believers to temple via road network
	# Pick believers closest to the sending shelter so the right ones visually walk away
	var sorted_believers := believers.duplicate()
	sorted_believers.sort_custom(func(a, b): return a.position.distance_to(home_pos) < b.position.distance_to(home_pos))
	var nodes: Array = []
	var sent := 0
	var shelter_door: Vector2 = SHELTER_POS + Vector2(0, 40)
	for b in sorted_believers:
		if sent >= wanted:
			break
		believers.erase(b)
		nodes.append(b)
		var spread_x := (sent - (wanted - 1) * 0.5) * 18.0
		var target := temple.position + Vector2(spread_x, 48)
		if shelter_idx == 0:
			# Step 1: walk to shelter exit (clears building collision)
			# Step 2: _walk_via_road handles EXIT_SOUTH or L-corner to temple
			var shelter_exit := home_pos
			var _b: CharacterBody2D = b
			var _target: Vector2 = target
			b.walk_to(shelter_exit)
			b.reached_forced_target.connect(func():
				_walk_via_road(_b, shelter_exit, _target, func(): pass)
			, CONNECT_ONE_SHOT)
		else:
			# Extra shelter → main shelter door → temple
			var extra_exit := home_pos
			var _b: CharacterBody2D = b
			var _target: Vector2 = target
			b.walk_to(extra_exit)
			b.reached_forced_target.connect(func():
				_walk_via_road(_b, extra_exit, shelter_door, func():
					_walk_via_road(_b, shelter_door, _target, func(): pass)
				)
			, CONNECT_ONE_SHOT)
		sent += 1
	# Hide after walk time — use full path length for extra shelters
	var temple_center := temple.position + Vector2(0, 48)
	var path_dist: float
	if shelter_idx == 0:
		var door_pos: Vector2 = home_pos + Vector2(0, 40)
		var rc := _road_corner(door_pos, temple_center)
		path_dist = door_pos.distance_to(rc) + rc.distance_to(temple_center)
	else:
		var extra_door: Vector2 = home_pos + Vector2(0, 48)
		var rc2 := _road_corner(shelter_door, temple_center)
		path_dist = extra_door.distance_to(shelter_door) + shelter_door.distance_to(rc2) + rc2.distance_to(temple_center)
	var walk_time := path_dist / 35.0 + 2.0
	var nodes_ref := nodes
	get_tree().create_timer(walk_time).timeout.connect(func():
		for b in nodes_ref:
			if is_instance_valid(b):
				b.visible = false
				b.park()
	)
	var row: VBoxContainer = temple_panel.add_prayer_session_row(wanted)
	# Create session dict
	var sess := {
		"count": wanted, "timer": PRAYER_TIME, "accumulator": 0.0,
		"nodes": nodes, "home_pos": home_pos, "shelter_idx": shelter_idx,
		"row": row, "bar": row.get_node("bar_bg/bar")
	}
	prayer_sessions.append(sess)
	# Update calling shelter's UI
	if selector_row:
		selector_row.visible = false
	if go_btn:
		go_btn.visible = false
	if progress_container:
		progress_container.visible = true
	if shelter_idx == 0:
		_update_prayer_ui()
	else:
		_update_extra_prayer_ui()
	_refresh_temple_panel()

func _on_pray_rush_pressed():
	if faith < 1:
		return
	faith -= 1
	# Rush the main shelter's session
	for i in range(prayer_sessions.size()):
		var sess: Dictionary = prayer_sessions[i]
		if sess.shelter_idx == 0:
			sess.timer = max(0.0, sess.timer - 600.0)
			if sess.timer <= 0.0:
				_complete_prayer_session(i)
			else:
				_update_prayer_ui()
			return


func _update_prayer_ui():
	for s in prayer_sessions:
		if s.shelter_idx == 0:
			var mins := int(s.timer) / 60
			var secs := int(s.timer) % 60
			var s_plural := "s" if s.count > 1 else ""
			pray_status_label.text = "Praying: %d believer%s — %d:%02d  (+%d faith/min)" % [
				s.count, s_plural, mins, secs, s.count]
			pray_bar.anchor_right = 1.0 - (s.timer / PRAYER_TIME)
			pray_rush_btn.disabled = faith < 1
			return
	_reset_prayer_ui()


func _update_extra_prayer_ui():
	if extra_pray_progress_container == null:
		return
	for s in prayer_sessions:
		if s.shelter_idx == current_extra_shelter_idx:
			var mins := int(s.timer) / 60
			var secs := int(s.timer) % 60
			(extra_pray_progress_container.get_child(0) as Label).text = \
				"Praying: %d — %d:%02d  (+%d faith/min)" % [s.count, mins, secs, s.count]
			return


func _complete_prayer_session(idx: int):
	var sess: Dictionary = prayer_sessions[idx]
	prayer_sessions.remove_at(idx)
	# Return believers to their home shelter via road network
	var sdoor: Vector2 = SHELTER_POS + Vector2(0, 40)
	for b in sess.nodes:
		if not is_instance_valid(b):
			continue
		b.position = temple.position + Vector2(randf_range(-15, 15), 40)
		b.visible = true
		believers.append(b)
		var home_offset: Vector2 = Vector2(randf_range(-30, 30), randf_range(-15, 15))
		var dest: Vector2 = sess.home_pos + home_offset
		if sess.shelter_idx == 0:
			_walk_via_road(b, sdoor, dest, func(): b.start_wandering(dest))
		else:
			# temple → main shelter door → extra shelter
			var temple_exit: Vector2 = temple.position + Vector2(0, 48)
			_walk_via_road(b, temple_exit, sdoor, func():
				_walk_via_road(b, sdoor, dest, func(): b.start_wandering(dest))
			)
	# Remove this session's temple row
	if is_instance_valid(sess.row):
		sess.row.queue_free()
	temple_panel.refresh_session_rows()
	_refresh_temple_panel()
	# Reset the correct shelter's UI
	if sess.shelter_idx == 0:
		_reset_prayer_ui()
	else:
		_reset_extra_prayer_ui()


func _reset_prayer_ui():
	pray_progress_container.visible = false
	pray_selector_row.visible = false
	pray_go_btn.visible = true
	pray_go_btn.disabled = believers_count <= 0 or temple == null or _praying_count() >= 5
	shelter_believer_label.text = "%d / 5" % mini(believers_count, 5)


func _reset_extra_prayer_ui():
	if extra_pray_progress_container == null:
		return
	extra_pray_progress_container.visible = false
	if extra_pray_selector_row:
		extra_pray_selector_row.visible = false
	if extra_pray_go_btn:
		extra_pray_go_btn.visible = true
		var in_shelter: int = clamp(believers_count - current_extra_shelter_idx * 5, 0, 5)
		extra_pray_go_btn.disabled = in_shelter <= 0 or temple == null or _praying_count() >= 5


func _update_pray_selector_label():
	pray_selector_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	pray_selector_label.text_direction = Control.TEXT_DIRECTION_LTR
	var s := "s" if prayer_selector_count > 1 else ""
	pray_selector_label.text = "%d believer%s" % [prayer_selector_count, s]


func _build_temple_panel(ui: CanvasLayer):
	temple_panel = TEMPLE_PANEL_SCENE.instantiate()
	ui.add_child(temple_panel)


func _build_garrison_panel(ui: CanvasLayer):
	garrison_panel = BuildingPanelFactoryScript.make_panel(ui, Color(0.75, 0.22, 0.14), "Garrison")
	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(garrison_panel)

	garrison_soldier_label = BuildingPanelFactoryScript.count_row(body, "Soldiers housed", Color(0.90, 0.55, 0.18))

	BuildingPanelFactoryScript.panel_sep(body, Color(0.75, 0.22, 0.14))

	# ── Go on a Crusade button ──
	crusade_go_btn = Button.new()
	crusade_go_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	crusade_go_btn.text = "⚔  Go on a Crusade   (2 hr)"
	crusade_go_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	BuildingPanelFactoryScript.style_action_btn(crusade_go_btn, Color(0.75, 0.22, 0.14))
	crusade_go_btn.pressed.connect(_on_crusade_pressed)
	body.add_child(crusade_go_btn)

	# ── Selector row (hidden until button tapped) ──
	crusade_selector_row = HBoxContainer.new()
	crusade_selector_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	crusade_selector_row.add_theme_constant_override("separation", 6)
	crusade_selector_row.visible = false
	body.add_child(crusade_selector_row)

	var minus_btn := Button.new()
	minus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	minus_btn.text = "−"
	minus_btn.custom_minimum_size = Vector2(32, 0)
	minus_btn.pressed.connect(func():
		crusade_selector_count = max(1, crusade_selector_count - 1)
		_update_crusade_selector_label())
	crusade_selector_row.add_child(minus_btn)

	crusade_selector_label = Label.new()
	crusade_selector_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	crusade_selector_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crusade_selector_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crusade_selector_label.add_theme_font_size_override("font_size", 13)
	crusade_selector_row.add_child(crusade_selector_label)

	var plus_btn := Button.new()
	plus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	plus_btn.text = "+"
	plus_btn.custom_minimum_size = Vector2(32, 0)
	plus_btn.pressed.connect(func():
		crusade_selector_count = min(soldiers_in_garrison, crusade_selector_count + 1)
		_update_crusade_selector_label())
	crusade_selector_row.add_child(plus_btn)

	var send_btn := Button.new()
	send_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	send_btn.text = "March →"
	BuildingPanelFactoryScript.style_action_btn(send_btn, Color(0.75, 0.22, 0.14))
	send_btn.pressed.connect(_on_crusade_confirm_pressed)
	crusade_selector_row.add_child(send_btn)

	# ── Bring Marcus toggle (hidden until he's available) ──
	crusade_bring_marcus_btn = Button.new()
	crusade_bring_marcus_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	crusade_bring_marcus_btn.text = "⚔ Bring Marcus as Leader"
	crusade_bring_marcus_btn.toggle_mode = true
	crusade_bring_marcus_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crusade_bring_marcus_btn.visible = false
	BuildingPanelFactoryScript.style_action_btn(crusade_bring_marcus_btn, Color(0.80, 0.55, 0.10))
	crusade_selector_row.get_parent().add_child(crusade_bring_marcus_btn)   # sibling of selector_row, inside body

	# ── Progress area (hidden until mission started) ──
	crusade_progress_container = VBoxContainer.new()
	crusade_progress_container.layout_direction = Control.LAYOUT_DIRECTION_LTR
	crusade_progress_container.add_theme_constant_override("separation", 6)
	crusade_progress_container.visible = false
	body.add_child(crusade_progress_container)

	crusade_timer_label = Label.new()
	crusade_timer_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	crusade_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crusade_timer_label.add_theme_font_size_override("font_size", 13)
	crusade_timer_label.add_theme_color_override("font_color", Color(0.92, 0.90, 0.98))
	crusade_progress_container.add_child(crusade_timer_label)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.18, 0.08, 0.08)
	bar_bg.custom_minimum_size = Vector2(0, 12)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crusade_progress_container.add_child(bar_bg)

	crusade_bar = ColorRect.new()
	crusade_bar.color = Color(0.85, 0.25, 0.10)
	crusade_bar.anchor_top    = 0.0
	crusade_bar.anchor_bottom = 1.0
	crusade_bar.anchor_left   = 0.0
	crusade_bar.anchor_right  = 0.0
	bar_bg.add_child(crusade_bar)

	crusade_rush_btn = Button.new()
	crusade_rush_btn.layout_direction = Control.LAYOUT_DIRECTION_LTR
	crusade_rush_btn.text = "⚡ Rush  (1 Faith = -10 min)"
	crusade_rush_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	BuildingPanelFactoryScript.style_action_btn(crusade_rush_btn, Color(0.72, 0.55, 1.00))
	crusade_rush_btn.pressed.connect(_on_crusade_rush_pressed)
	crusade_progress_container.add_child(crusade_rush_btn)

	BuildingPanelFactoryScript.panel_sep(body, Color(0.75, 0.22, 0.14))

	var upg := Button.new()
	upg.layout_direction = Control.LAYOUT_DIRECTION_LTR
	upg.text = "⬆  Upgrade Building   (Coming Soon)"
	upg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upg.disabled = true
	BuildingPanelFactoryScript.style_action_btn(upg, Color(0.50, 0.48, 0.44))
	body.add_child(upg)


func _build_tutorial_panel(ui: CanvasLayer):
	# Full-screen overlay — blocks input while popup is showing
	tutorial_overlay = ColorRect.new()
	tutorial_overlay.layout_direction = Control.LAYOUT_DIRECTION_LTR
	tutorial_overlay.anchor_left   = 0.0
	tutorial_overlay.anchor_right  = 1.0
	tutorial_overlay.anchor_top    = 0.0
	tutorial_overlay.anchor_bottom = 1.0
	tutorial_overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_overlay.visible = false
	ui.add_child(tutorial_overlay)

	# Centered popup card (DragonVale style)
	tutorial_popup = PanelContainer.new()
	tutorial_popup.layout_direction = Control.LAYOUT_DIRECTION_LTR
	tutorial_popup.anchor_left   = 0.5
	tutorial_popup.anchor_right  = 0.5
	tutorial_popup.anchor_top    = 0.5
	tutorial_popup.anchor_bottom = 0.5
	tutorial_popup.offset_left   = -235
	tutorial_popup.offset_right  = 235
	tutorial_popup.offset_top    = -115
	tutorial_popup.offset_bottom = 115
	var _popup_style := StyleBoxFlat.new()
	_popup_style.bg_color = Color(0.08, 0.06, 0.16, 0.97)
	_popup_style.border_color = Color(0.85, 0.68, 0.15)
	_popup_style.set_border_width_all(3)
	_popup_style.set_corner_radius_all(12)
	_popup_style.content_margin_left   = 14
	_popup_style.content_margin_right  = 14
	_popup_style.content_margin_top    = 12
	_popup_style.content_margin_bottom = 12
	tutorial_popup.add_theme_stylebox_override("panel", _popup_style)
	tutorial_popup.visible = false
	ui.add_child(tutorial_popup)

	var _hbox := HBoxContainer.new()
	_hbox.add_theme_constant_override("separation", 14)
	tutorial_popup.add_child(_hbox)

	# Leader portrait on the left. Keep it boxed so tall character art cannot
	# expand the tutorial popup and push the OK button out of reach.
	var _portrait_frame := Control.new()
	_portrait_frame.custom_minimum_size = Vector2(100, 150)
	_portrait_frame.clip_contents = true
	_portrait_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_hbox.add_child(_portrait_frame)

	var _portrait := TextureRect.new()
	_portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var _portrait_path: String
	match GameData.selected_leader:
		0: _portrait_path = "res://assets/characters/leaders/High Priest.png"
		1: _portrait_path = "res://assets/characters/leaders/Prophet of Wealth.png"
		2: _portrait_path = "res://assets/characters/leaders/Holy General.png"
		_: _portrait_path = "res://assets/characters/leaders/High Priest.png"
	_portrait.texture = load(_portrait_path)
	_portrait_frame.add_child(_portrait)

	# Right side: leader name + speech text + OK button
	var _vbox := VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox.add_theme_constant_override("separation", 8)
	_hbox.add_child(_vbox)

	var _name_lbl := Label.new()
	_name_lbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	_name_lbl.text = GameData.leader_name
	_name_lbl.add_theme_font_size_override("font_size", 17)
	_name_lbl.add_theme_color_override("font_color", Color(0.95, 0.80, 0.25))
	_vbox.add_child(_name_lbl)

	tutorial_popup_text = Label.new()
	tutorial_popup_text.layout_direction = Control.LAYOUT_DIRECTION_LTR
	tutorial_popup_text.text = ""
	tutorial_popup_text.add_theme_font_size_override("font_size", 14)
	tutorial_popup_text.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))
	tutorial_popup_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_popup_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_vbox.add_child(tutorial_popup_text)

	var _btn_row := HBoxContainer.new()
	_btn_row.alignment = BoxContainer.ALIGNMENT_END
	_vbox.add_child(_btn_row)

	var _ok_btn := Button.new()
	_ok_btn.text = "OK"
	_ok_btn.custom_minimum_size = Vector2(80, 36)
	_ok_btn.pressed.connect(_on_tutorial_popup_ok)
	_btn_row.add_child(_ok_btn)

	# ── Arrow hints (shown after popup is dismissed) ──────────────────────────

	# Floating badge that tracks the Humble Shelter on the map (TAP_SHELTER step)
	shelter_arrow = PanelContainer.new()
	shelter_arrow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	shelter_arrow.anchor_left   = 0.0
	shelter_arrow.anchor_right  = 0.0
	shelter_arrow.anchor_top    = 0.0
	shelter_arrow.anchor_bottom = 0.0
	shelter_arrow.offset_left   = 0
	shelter_arrow.offset_right  = 180
	shelter_arrow.offset_top    = 0
	shelter_arrow.offset_bottom = 36
	var _sa_style := StyleBoxFlat.new()
	_sa_style.bg_color = Color(0.05, 0.04, 0.10, 0.88)
	_sa_style.border_color = Color(0.95, 0.15, 0.15)
	_sa_style.set_border_width_all(2)
	_sa_style.set_corner_radius_all(7)
	_sa_style.content_margin_left  = 10
	_sa_style.content_margin_right = 10
	_sa_style.content_margin_top   = 5
	_sa_style.content_margin_bottom = 5
	shelter_arrow.add_theme_stylebox_override("panel", _sa_style)
	shelter_arrow.visible = false
	ui.add_child(shelter_arrow)

	shelter_arrow_label = Label.new()
	shelter_arrow_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	shelter_arrow_label.text = "↓  Tap Shelter"
	shelter_arrow_label.add_theme_font_size_override("font_size", 17)
	shelter_arrow_label.add_theme_color_override("font_color", Color(0.95, 0.15, 0.15))
	shelter_arrow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shelter_arrow.add_child(shelter_arrow_label)

	# "Tap Rush →" label on the LEFT side of the Rush button row, pointing right
	rush_tutorial_arrow = Label.new()
	rush_tutorial_arrow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	rush_tutorial_arrow.text = "Tap Rush →"
	rush_tutorial_arrow.add_theme_font_size_override("font_size", 14)
	rush_tutorial_arrow.add_theme_color_override("font_color", Color(1.0, 0.30, 0.30))
	rush_tutorial_arrow.anchor_left   = 0.0
	rush_tutorial_arrow.anchor_right  = 0.0
	rush_tutorial_arrow.anchor_top    = 1.0
	rush_tutorial_arrow.anchor_bottom = 1.0
	rush_tutorial_arrow.offset_left   = 16
	rush_tutorial_arrow.offset_right  = 160
	rush_tutorial_arrow.offset_top    = -82
	rush_tutorial_arrow.offset_bottom = -60
	rush_tutorial_arrow.visible = false
	ui.add_child(rush_tutorial_arrow)

	# Floating badge below the Wheel of Faith chip (WHEEL_HINT step)
	wheel_tutorial_arrow = PanelContainer.new()
	wheel_tutorial_arrow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	wheel_tutorial_arrow.anchor_left   = 0.0
	wheel_tutorial_arrow.anchor_right  = 0.0
	wheel_tutorial_arrow.anchor_top    = 0.0
	wheel_tutorial_arrow.anchor_bottom = 0.0
	wheel_tutorial_arrow.offset_top    = 58
	wheel_tutorial_arrow.offset_bottom = 94
	var _wa_style := StyleBoxFlat.new()
	_wa_style.bg_color = Color(0.05, 0.04, 0.10, 0.90)
	_wa_style.border_color = Color(0.95, 0.15, 0.15)
	_wa_style.set_border_width_all(2)
	_wa_style.set_corner_radius_all(7)
	_wa_style.content_margin_left   = 8
	_wa_style.content_margin_right  = 8
	_wa_style.content_margin_top    = 4
	_wa_style.content_margin_bottom = 4
	wheel_tutorial_arrow.add_theme_stylebox_override("panel", _wa_style)
	wheel_tutorial_arrow.visible = false
	var _wa_lbl := Label.new()
	_wa_lbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	_wa_lbl.text = "↑  Tap to Spin!"
	_wa_lbl.add_theme_font_size_override("font_size", 14)
	_wa_lbl.add_theme_color_override("font_color", Color(0.95, 0.15, 0.15))
	wheel_tutorial_arrow.add_child(_wa_lbl)
	ui.add_child(wheel_tutorial_arrow)

	# Floating toast label for quick error feedback ("not enough gold", etc.)
	tutorial_label = Label.new()
	tutorial_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	tutorial_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	tutorial_label.offset_top    = 52
	tutorial_label.offset_bottom = 80
	tutorial_label.offset_left   = -300
	tutorial_label.offset_right  =  300
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.add_theme_font_size_override("font_size", 14)
	tutorial_label.add_theme_color_override("font_color", Color(1.0, 0.30, 0.20))
	tutorial_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	tutorial_label.add_theme_constant_override("shadow_offset_x", 1)
	tutorial_label.add_theme_constant_override("shadow_offset_y", 1)
	tutorial_label.text = ""
	ui.add_child(tutorial_label)


func _build_construction_panel(ui: CanvasLayer):
	construction_panel = PanelContainer.new()
	construction_panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	construction_panel.anchor_left   = 0.0
	construction_panel.anchor_right  = 1.0
	construction_panel.anchor_top    = 1.0
	construction_panel.anchor_bottom = 1.0
	construction_panel.offset_left   = 8
	construction_panel.offset_right  = -8
	construction_panel.offset_top    = -155
	construction_panel.offset_bottom = -48
	construction_panel.visible = false

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.05, 0.02, 0.95)
	panel_style.border_color = Color(0.72, 0.54, 0.16)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_top    = 8
	panel_style.content_margin_bottom = 8
	panel_style.content_margin_left   = 14
	panel_style.content_margin_right  = 14
	construction_panel.add_theme_stylebox_override("panel", panel_style)
	ui.add_child(construction_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 7)
	construction_panel.add_child(vbox)

	# Title: building name + countdown
	construction_label = Label.new()
	construction_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	construction_label.text = "Building — 5:00"
	construction_label.add_theme_font_size_override("font_size", 15)
	construction_label.add_theme_color_override("font_color", Color(0.98, 0.84, 0.34))
	construction_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	construction_label.add_theme_constant_override("shadow_offset_x", 1)
	construction_label.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(construction_label)

	# Progress bar — dark bg with amber fill and shine strip
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.06, 0.04, 0.01)
	bar_bg.custom_minimum_size = Vector2(0, 20)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(bar_bg)

	construction_bar = ColorRect.new()
	construction_bar.color = Color(0.88, 0.62, 0.12)
	construction_bar.anchor_top    = 0.0
	construction_bar.anchor_bottom = 1.0
	construction_bar.anchor_left   = 0.0
	construction_bar.anchor_right  = 0.0
	bar_bg.add_child(construction_bar)

	var bar_shine := ColorRect.new()
	bar_shine.color = Color(1.0, 0.96, 0.55, 0.45)
	bar_shine.anchor_top    = 0.0
	bar_shine.anchor_bottom = 0.0
	bar_shine.anchor_left   = 0.0
	bar_shine.anchor_right  = 1.0
	bar_shine.offset_top    = 2
	bar_shine.offset_bottom = 7
	construction_bar.add_child(bar_shine)

	# Rush button — warm amber style
	rush_button = Button.new()
	rush_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	rush_button.text = "⚡  Rush!  (1 Faith Point)"
	rush_button.add_theme_font_size_override("font_size", 14)
	rush_button.add_theme_color_override("font_color",          Color(1.00, 0.92, 0.28))
	rush_button.add_theme_color_override("font_hover_color",    Color(1.00, 0.98, 0.55))
	rush_button.add_theme_color_override("font_pressed_color",  Color(0.90, 0.78, 0.18))
	rush_button.add_theme_color_override("font_disabled_color", Color(0.55, 0.44, 0.22))
	rush_button.pressed.connect(_on_rush_pressed)

	var _btn_mk := func(bg: Color, border: Color) -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color = bg; s.border_color = border
		s.set_border_width_all(2); s.set_corner_radius_all(6)
		s.content_margin_top = 5; s.content_margin_bottom = 5
		s.content_margin_left = 14; s.content_margin_right = 14
		return s
	rush_button.add_theme_stylebox_override("normal",   _btn_mk.call(Color(0.38, 0.22, 0.05), Color(0.78, 0.58, 0.16)))
	rush_button.add_theme_stylebox_override("hover",    _btn_mk.call(Color(0.52, 0.32, 0.08), Color(0.95, 0.74, 0.24)))
	rush_button.add_theme_stylebox_override("pressed",  _btn_mk.call(Color(0.25, 0.14, 0.03), Color(0.60, 0.44, 0.12)))
	rush_button.add_theme_stylebox_override("disabled", _btn_mk.call(Color(0.18, 0.14, 0.08), Color(0.38, 0.30, 0.16)))
	vbox.add_child(rush_button)


func _update_construction_ui():
	var mins := int(active_construction_timer) / 60
	var secs := int(active_construction_timer) % 60
	var bname: String
	match active_construction_type:
		"temple":           bname = "Small Temple"
		"hall_of_devoted":  bname = "Hall of the Devoted"
		"preacher_shelter": bname = "Preacher Shelter"
		"armory":           bname = "Barracks"
		"garrison":         bname = "Garrison"
		"generals_quarters": bname = "General's Quarters"
		"shelter":          bname = "Believer Shelter"
		"well":             bname = "Wishing Well"
		"garden":           bname = "Pumpkin Garden"
		"stone_pool":       bname = "Stone Pool"
		_:                  bname = "Building"
	construction_label.text = "%s — %d:%02d remaining" % [bname, mins, secs]
	rush_button.disabled = faith < 1
	rush_button.text = "⚡  Rush!  (1 Faith Point)" if faith >= 1 else "⚡  Rush!  (need Faith)"
	var progress := 1.0 - (active_construction_timer / active_construction_max)
	construction_bar.anchor_right = progress

	# Pulse rush button during RUSH_PROMPT tutorial step
	if tut_step == TutStep.RUSH_PROMPT and faith >= 1 and tut_popup_dismissed:
		rush_pulse += get_process_delta_time() * 3.0
		var t := (sin(rush_pulse) + 1.0) * 0.5
		rush_button.modulate = Color(1.0, lerp(0.65, 1.0, t), lerp(0.20, 0.65, t))
	else:
		rush_button.modulate = Color.WHITE
		rush_pulse = 0.0


func _update_conversion_ui():
	var mins := int(conversion_timer) / 60
	var secs := int(conversion_timer) % 60
	conversion_label.text = "Converting — %d:%02d remaining" % [mins, secs]
	convert_btn.disabled = true
	convert_btn.text = "Converting… (%d:%02d)" % [mins, secs]
	var progress := 1.0 - (conversion_timer / CONVERSION_TIME)
	conversion_bar.anchor_right = progress
	conversion_rush_btn.visible = true
	conversion_rush_btn.disabled = faith < 1
	conversion_rush_btn.text = "⚡ -10m" if faith >= 1 else "⚡ need Faith"


# ── Tutorial logic ────────────────────────────────────────────────────────────
func _update_tutorial():
	if tutorial_label:
		tutorial_label.text = ""
	var popup_showing: bool = !tut_popup_dismissed and tut_step != TutStep.DONE

	if tutorial_overlay:
		tutorial_overlay.visible = popup_showing
	if tutorial_popup:
		tutorial_popup.visible = popup_showing
		if popup_showing and tutorial_popup_text:
			tutorial_popup_text.text = TutorialCopyScript.speech(tut_step, GameData.leader_name)

	# When PLACE_TEMPLE popup is dismissed, reveal the ghost and activate placement
	if tut_step == TutStep.PLACE_TEMPLE and tut_popup_dismissed and ghost_node != null:
		ghost_node.visible = true
		placing_building   = true

	# Arrows only appear after the popup for that step is dismissed
	if rush_tutorial_arrow:
		rush_tutorial_arrow.visible = tut_popup_dismissed and tut_step == TutStep.RUSH_PROMPT
	if shelter_arrow:
		shelter_arrow.visible = tut_popup_dismissed and tut_step == TutStep.TAP_SHELTER
	if pray_tutorial_arrow:
		pray_tutorial_arrow.visible = tut_popup_dismissed and tut_step == TutStep.TAP_GO_PRAY
	if wheel_tutorial_arrow:
		wheel_tutorial_arrow.visible = tut_popup_dismissed and tut_step == TutStep.WHEEL_HINT
		if tut_popup_dismissed and tut_step == TutStep.WHEEL_HINT and wheel_chip_node != null:
			var chip_pos := wheel_chip_node.global_position
			wheel_tutorial_arrow.offset_left  = chip_pos.x
			wheel_tutorial_arrow.offset_right = chip_pos.x + wheel_chip_node.size.x + 20
	if build_menu != null:
		build_menu.set_temple_hint_visible(tut_popup_dismissed and tut_step == TutStep.BUILD_TEMPLE)


func _on_tutorial_popup_ok():
	match tut_step:
		TutStep.INTRO:
			tut_step = TutStep.BUILD_TEMPLE
			tut_popup_dismissed = false
		TutStep.TEMPLE_COMPLETE:
			tut_step = TutStep.TAP_SHELTER
			tut_popup_dismissed = false
		TutStep.COMPLETE:
			tut_step = TutStep.WHEEL_HINT
			tut_popup_dismissed = false
		_:
			tut_popup_dismissed = true
	_update_tutorial()


func _pulse_build_button(delta: float):
	if tut_step == TutStep.BUILD_TEMPLE and tut_popup_dismissed:
		highlight_pulse += delta * 3.0
		var t := (sin(highlight_pulse) + 1.0) * 0.5
		build_button.modulate = Color(1.0, lerp(0.55, 1.0, t), lerp(0.15, 0.55, t))
		# Pulse the rush arrow between bright red and soft red
		if rush_tutorial_arrow and rush_tutorial_arrow.visible:
			var t2 := (sin(highlight_pulse) + 1.0) * 0.5
			rush_tutorial_arrow.add_theme_color_override("font_color",
				Color(1.0, lerp(0.20, 0.45, t2), lerp(0.20, 0.45, t2)))
		# Pulse the temple indicator arrow between bright red and dim red
		if build_menu != null and build_menu.is_temple_hint_visible():
			var arrow_color := Color(1.0, lerp(0.15, 0.35, t), lerp(0.15, 0.35, t), lerp(0.6, 1.0, t))
			build_menu.set_temple_hint_color(arrow_color)
	elif (tut_step == TutStep.TAP_SHELTER or tut_step == TutStep.TAP_GO_PRAY) and tut_popup_dismissed:
		highlight_pulse += delta * 3.0
		# Pulse the shelter / pray arrows
		if shelter_arrow_label and shelter_arrow and shelter_arrow.visible:
			var t := (sin(highlight_pulse) + 1.0) * 0.5
			shelter_arrow_label.add_theme_color_override("font_color",
				Color(1.0, lerp(0.10, 0.40, t), lerp(0.10, 0.40, t)))
		if pray_tutorial_arrow and pray_tutorial_arrow.visible:
			var t := (sin(highlight_pulse) + 1.0) * 0.5
			pray_tutorial_arrow.add_theme_color_override("font_color",
				Color(1.0, lerp(0.20, 0.50, t), lerp(0.20, 0.50, t)))
		if wheel_tutorial_arrow and wheel_tutorial_arrow.visible:
			var t2 := (sin(highlight_pulse) + 1.0) * 0.5
			var lbl2 := wheel_tutorial_arrow.get_child(0) as Label
			if lbl2:
				lbl2.add_theme_color_override("font_color",
					Color(1.0, lerp(0.15, 0.45, t2), lerp(0.15, 0.45, t2)))
	else:
		build_button.modulate = Color.WHITE
		highlight_pulse = 0.0


# ── Build actions ─────────────────────────────────────────────────────────────
func _on_build_pressed():
	if placing_road:
		_cancel_road_placement()
	if placing_building:
		_cancel_placement()
		return
	build_menu.toggle_menu()


func _on_build_menu_road_requested(type: String) -> void:
	_start_road_placement(type)


func _on_build_menu_build_requested(type: String, cost: int) -> void:
	match type:
		"temple":
			if temple != null:
				return
		"hall_of_devoted":
			if hall_of_devoted != null:
				return
		"preacher_shelter":
			if preacher_shelter_building != null:
				return
		"armory":
			if armory != null:
				return
		"garrison":
			if garrison != null:
				return
		"generals_quarters":
			if generals_quarters != null or not marcus_obtained:
				return
	_try_start_placement(type, cost)


func _try_start_placement(type: String, cost: int):
	if active_construction_timer > 0.0:
		tutorial_label.text = "Finish the current construction first!"
		get_tree().create_timer(2.0).timeout.connect(_update_tutorial)
		return
	if gold < cost:
		tutorial_label.text = "Not enough gold! You need %d gold." % cost
		get_tree().create_timer(2.0).timeout.connect(_update_tutorial)
		return
	gold -= cost
	placing_cost = cost
	build_menu.hide_menu()
	_start_placement(type)


# ── Placement mode ────────────────────────────────────────────────────────────
func _start_placement(type: String):
	placing_building = true
	placing_type = type
	ghost_node = BUILDING_SCENES.get(type, BUILDING_SCENES["shelter"]).instantiate()
	ghost_node.building_type    = type
	ghost_node.building_label   = ""
	ghost_node.is_interactive   = false
	ghost_node.modulate         = Color(0.60, 1.0, 0.60, 0.55)
	ghost_node.position         = get_viewport().get_mouse_position()
	world.add_child(ghost_node)

	if type == "temple" and tut_step == TutStep.BUILD_TEMPLE:
		tut_step = TutStep.PLACE_TEMPLE
		tut_popup_dismissed = false
		if build_menu != null:
			build_menu.set_temple_hint_visible(false)
		# Hide ghost until player dismisses the popup
		ghost_node.visible = false
		placing_building   = false
		_update_tutorial()


func _cancel_placement():
	placing_building = false
	if ghost_node:
		ghost_node.queue_free()
		ghost_node = null
	gold += placing_cost   # refund
	if placing_type == "temple" and tut_step == TutStep.PLACE_TEMPLE:
		tut_step = TutStep.BUILD_TEMPLE
		tut_popup_dismissed = false
		_update_tutorial()
	placing_type = ""
	placing_cost = 0


func _place_building(pos: Vector2):
	var type := placing_type
	placing_building = false
	placing_type = ""
	placing_cost = 0
	if ghost_node:
		ghost_node.queue_free()
		ghost_node = null

	var label: String
	var max_time: float
	match type:
		"temple":           label = "Small Temple";        max_time = CONSTRUCTION_TIME
		"hall_of_devoted":  label = "Hall of the Devoted"; max_time = HALL_CONSTRUCTION_TIME
		"preacher_shelter": label = "Preacher Shelter";    max_time = PREACHER_SHELTER_TIME
		"shelter":          label = "Believer Shelter";    max_time = SHELTER_UPGRADE_TIME
		"armory":           label = "Barracks";            max_time = ARMORY_CONSTRUCTION_TIME
		"garrison":         label = "Garrison";            max_time = GARRISON_CONSTRUCTION_TIME
		"generals_quarters": label = "General's Quarters"; max_time = GENERALS_QUARTERS_TIME
		"well":             label = "Wishing Well";        max_time = DECORATION_BUILD_TIME
		"garden":           label = "Pumpkin Garden";      max_time = DECORATION_BUILD_TIME
		"stone_pool":       label = "Stone Pool";          max_time = DECORATION_BUILD_TIME

	var b := _make_building(type, pos, label, false)
	b.set_meta("under_construction", true)
	b.queue_redraw()

	match type:
		"temple":             temple                    = b
		"hall_of_devoted":    hall_of_devoted           = b
		"preacher_shelter":   preacher_shelter_building = b
		"armory":             armory                    = b
		"garrison":           garrison                  = b
		"shelter":            pass   # multiple allowed, tracked by believer_shelter_count

	blocked_zones.append({"pos": pos, "radius": 85.0})

	active_construction_node  = b
	active_construction_type  = type
	active_construction_max   = max_time
	active_construction_timer = max_time
	construction_panel.visible = true
	_update_construction_ui()

	if type == "temple" and tut_step == TutStep.PLACE_TEMPLE:
		tut_step = TutStep.RUSH_PROMPT
		tut_popup_dismissed = false
		_update_tutorial()


func _complete_construction():
	var type := active_construction_type
	var b    := active_construction_node
	active_construction_timer = 0.0
	active_construction_node  = null
	active_construction_type  = ""
	construction_panel.visible = false

	b.is_interactive = true
	b.remove_meta("under_construction")
	b.queue_redraw()

	match type:
		"temple":
			temple = b
			b.tapped.connect(_on_temple_tapped)
			_show_road_hint("Believers need a road to reach the Temple!\nTap Build → Roads to lay a path.")
			if tut_step == TutStep.RUSH_PROMPT:
				tut_step = TutStep.TEMPLE_COMPLETE
				tut_popup_dismissed = false
				_update_tutorial()
		"hall_of_devoted":
			b.tapped.connect(_on_hall_tapped)
			_show_road_hint("Connect the Hall of the Devoted to the Shelter with a road\nso Believers can walk there to become Preachers.")
			_reset_conversion_ui()
		"preacher_shelter":
			preacher_shelter_built = true
			b.tapped.connect(_on_preacher_shelter_tapped)
			_show_road_hint("Build a road from the Hall to the Preacher Shelter\nso converted Preachers can reach their home.")
			# If a preacher was waiting at the hall, send them over now
			if preacher_waiting_at_hall and converting_node != null:
				preacher_waiting_at_hall = false
				_walk_via_road(converting_node, hall_of_devoted.position + Vector2(0, 20), preacher_shelter_building.position + Vector2(randf_range(-15, 15), 48), _on_preacher_arrived_at_shelter)
		"armory":
			armory_built = true
			b.tapped.connect(_on_armory_tapped)
			_show_road_hint("Build a road to the Barracks so Believers\ncan walk there to begin their training.")
			_reset_training_ui()
		"garrison":
			garrison_built = true
			b.tapped.connect(_on_garrison_tapped)
			_show_road_hint("Connect the Barracks to the Garrison with a road\nso trained Soldiers can march to their post.")
			# If a soldier was waiting at the barracks, send them over now
			if soldier_waiting_at_armory and training_node != null:
				soldier_waiting_at_armory = false
				_walk_via_road(training_node, armory.position + Vector2(0, 20), garrison.position + Vector2(randf_range(-15, 15), 48), _on_soldier_arrived_at_garrison)
		"generals_quarters":
			generals_quarters_built = true
			generals_quarters = b
			b.tapped.connect(_on_generals_quarters_tapped)
			# Spawn Marcus wandering around his new quarters
			marcus_character_node = MARCUS_SCENE.instantiate()
			world.add_child(marcus_character_node)
			marcus_character_node.setup(b.position + Vector2(0, 20))
		"well", "garden", "stone_pool":
			var _b := b
			b.tapped.connect(func(): _show_building_info(_b, _b.building_label))
		"shelter":
			believer_shelter_count += 1
			believer_capacity = believer_shelter_count * 5
			var shelter_ref := b
			extra_shelter_buildings.append(b)
			b.tapped.connect(func():
				shelter_panel.visible = false
				conversion_panel.visible = false
				training_panel.visible = false
				preacher_shelter_panel.visible = false
				garrison_panel.visible = false
				current_extra_shelter_idx = extra_shelter_buildings.find(shelter_ref) + 1
				_refresh_extra_shelter_panel()
				extra_shelter_panel.visible = true
			)


func _on_rush_pressed():
	if faith < 1:
		return
	faith -= 1
	active_construction_timer = max(0.0, active_construction_timer - 600.0)   # -10 min
	if active_construction_timer <= 0.0:
		_complete_construction()
	else:
		_update_construction_ui()


func _on_temple_tapped():
	conversion_panel.visible = false
	training_panel.visible = false
	preacher_shelter_panel.visible = false
	garrison_panel.visible = false
	shelter_panel.visible = false
	if extra_shelter_panel:
		extra_shelter_panel.visible = false
	temple_panel.toggle_panel()
	if temple_panel.visible:
		_refresh_temple_panel()


func _refresh_temple_panel():
	var total: int = 0
	for s in prayer_sessions:
		total += s.count
	temple_panel.set_praying_count(total)


func _on_hall_tapped():
	training_panel.visible = false
	preacher_shelter_panel.visible = false
	garrison_panel.visible = false
	shelter_panel.visible = false
	if extra_shelter_panel:
		extra_shelter_panel.visible = false
	conversion_panel.visible = not conversion_panel.visible
	if conversion_panel.visible:
		_reset_conversion_ui()


func _on_convert_pressed():
	# Block if already converting or a preacher is still waiting/walking
	if converting or converting_node != null or believers_count <= 1:
		return
	# Pick a believer node to physically walk to the hall
	var chosen: CharacterBody2D = null
	for b in believers:
		chosen = b
		break
	if chosen == null:
		return
	believers.erase(chosen)
	converting_node = chosen
	converting = true
	conversion_timer = CONVERSION_TIME
	# Walk to hall entrance via road
	_walk_via_road(chosen, SHELTER_POS + Vector2(0, 40), hall_of_devoted.position + Vector2(0, 20), _on_believer_arrived_at_hall)
	_update_conversion_ui()


func _on_believer_arrived_at_hall():
	# Believer enters the building — hide them
	if converting_node:
		converting_node.visible = false
		converting_node.park()


func _on_conversion_rush_pressed():
	if faith < 1:
		return
	faith -= 1
	conversion_timer = max(0.0, conversion_timer - 600.0)   # -10 minutes
	if conversion_timer <= 0.0:
		_complete_conversion()
	else:
		_update_conversion_ui()


func _complete_conversion():
	converting = false
	believers_count -= 1
	preachers_count += 1
	# Convert the node visually
	if converting_node:
		converting_node.is_preacher = true
		converting_node.queue_redraw()
		preachers.append(converting_node)
		if preacher_shelter_built and preacher_shelter_building != null:
			# Shelter already exists — send preacher there via road
			converting_node.visible = true
			converting_node.needs_shelter = false
			_walk_via_road(converting_node, hall_of_devoted.position + Vector2(0, 20), preacher_shelter_building.position + Vector2(randf_range(-15, 15), 48), _on_preacher_arrived_at_shelter)
		else:
			# No shelter yet — stand at hall door and wait
			preacher_waiting_at_hall = true
			converting_node.visible = true
			converting_node.position = hall_of_devoted.position + Vector2(0, 30)
			converting_node.needs_shelter = true
			converting_node.park()
			converting_node.queue_redraw()
	_reset_conversion_ui()


func _on_preacher_arrived_at_shelter():
	if converting_node:
		preachers_in_shelter += 1
		preacher_waiting_at_hall = false
		converting_node.needs_shelter = false
		converting_node.start_wandering(
			preacher_shelter_building.position + Vector2(randf_range(-35, 35), 80 + randf_range(-8, 8)))
		converting_node = null
	_reset_conversion_ui()


func _on_spread_pressed():
	if spreading or preachers_in_shelter <= 0:
		return
	spread_selector_count = min(1, preachers_in_shelter)
	_update_spread_selector_label()
	spread_go_btn.visible = false
	spread_selector_row.visible = true


func _update_spread_selector_label():
	spread_selector_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	spread_selector_label.text_direction = Control.TEXT_DIRECTION_LTR
	var s := "s" if spread_selector_count > 1 else ""
	spread_selector_label.text = "%d preacher%s" % [spread_selector_count, s]


func _on_spread_confirm_pressed():
	if spreading or spread_selector_count <= 0 or preachers_in_shelter < spread_selector_count:
		return
	spreading = true
	spread_sent = spread_selector_count
	spread_timer = SPREAD_TIME
	spread_selector_row.visible = false
	spread_progress_container.visible = true

	# Hide the sent preachers from their shelter
	var hidden := 0
	for p in preachers.duplicate():
		if hidden >= spread_sent:
			break
		spreading_nodes.append(p)
		p.visible = false
		hidden += 1
	preachers_in_shelter -= spread_sent
	_refresh_preacher_label()
	_update_spread_ui()


func _update_spread_ui():
	if not spreading:
		return
	var mins := int(spread_timer) / 60
	var secs := int(spread_timer) % 60
	var s := "s" if spread_sent > 1 else ""
	spread_label.text = "%d preacher%s spreading the faith — %d:%02d remaining" % [spread_sent, s, mins, secs]
	var progress := 1.0 - (spread_timer / SPREAD_TIME)
	spread_bar.anchor_right = progress
	spread_rush_btn.disabled = faith < 1


func _on_spread_rush_pressed():
	if faith < 1:
		return
	faith -= 1
	spread_timer = max(0.0, spread_timer - 600.0)
	if spread_timer <= 0.0:
		_complete_spread()
	else:
		_update_spread_ui()
	_refresh_resource_labels()


func _complete_spread():
	spreading = false
	spread_progress_container.visible = false
	spread_go_btn.visible = true

	# Simulate how many believers each preacher brings
	var brought := 0
	for i in range(spread_sent):
		var roll := randf()
		if roll < 0.20:
			brought += 0       # 20% — nobody this time
		elif roll < 0.60:
			brought += 1       # 40% — 1 convert
		elif roll < 0.90:
			brought += 2       # 30% — 2 converts
		else:
			brought += 3       # 10% — inspired crowd

	# Cap by available shelter capacity
	var available := believer_shelter_count * 5 - believers_count
	var actually_joined := mini(brought, available)
	believers_count += actually_joined
	_refresh_resource_labels()

	# Return preachers to shelter
	preachers_in_shelter += spread_sent
	_refresh_preacher_label()
	for p in spreading_nodes:
		if is_instance_valid(p) and preacher_shelter_building != null:
			p.visible = true
			_walk_via_road(p, hall_of_devoted.position + Vector2(0, 20),
				preacher_shelter_building.position + Vector2(randf_range(-15, 15), 48),
				func(): pass)
	spreading_nodes.clear()

	# Build result message
	var result := ""
	if actually_joined <= 0 and brought <= 0:
		result = "The crowd was unmoved this time...\nYour preachers return to rest."
	elif actually_joined < brought:
		result = "%d soul%s wished to join, but your shelters\nare full! Build more to welcome them.\n%d joined anyway." % [
			brought, "s" if brought > 1 else "",
			actually_joined]
	else:
		var s := "s" if actually_joined > 1 else ""
		result = "%d new soul%s have joined your faith!\nThey make their way to your shelter." % [actually_joined, s]
	spread_result_label.text = result
	spread_result_popup.visible = true

	# Spawn the new believers at the correct shelter based on slot index
	if actually_joined > 0:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		var start_count: int = believers_count - actually_joined
		for i in range(actually_joined):
			var b: CharacterBody2D = load("res://scenes/believer.tscn").instantiate()
			var shelter_idx: int = (start_count + i) / 5
			var spawn_pos: Vector2
			if shelter_idx == 0:
				spawn_pos = SHELTER_POS
			elif shelter_idx - 1 < extra_shelter_buildings.size():
				spawn_pos = extra_shelter_buildings[shelter_idx - 1].position
			else:
				spawn_pos = SHELTER_POS
			var offset := Vector2(rng.randf_range(-35, 35), rng.randf_range(-8, 8))
			world.add_child(b)
			b.setup(spawn_pos + Vector2(0, 80) + offset, believers.size())
			believers.append(b)


func _refresh_preacher_label():
	var total: int = preachers_in_shelter + (spread_sent if spreading else 0)
	shelter_preacher_label.text = "%d / 5" % total


func _reset_conversion_ui():
	if preacher_waiting_at_hall:
		conversion_label.text = "⚠  Preacher waiting — build Preacher Shelter!"
		convert_btn.disabled = true
		convert_btn.text = "Preacher needs a home first"
	else:
		conversion_label.text = "Ready to convert"
		convert_btn.disabled = believers_count <= 1 or converting_node != null
		convert_btn.text = "Convert Believer  (1 hr)"
	conversion_bar.anchor_right = 0.0
	conversion_rush_btn.visible = false


# ── Armory / soldier training ─────────────────────────────────────────────────
func _on_armory_tapped():
	conversion_panel.visible = false
	preacher_shelter_panel.visible = false
	garrison_panel.visible = false
	shelter_panel.visible = false
	if extra_shelter_panel:
		extra_shelter_panel.visible = false
	training_panel.visible = not training_panel.visible
	if training_panel.visible:
		_reset_training_ui()

func _on_garrison_tapped():
	conversion_panel.visible = false
	training_panel.visible = false
	preacher_shelter_panel.visible = false
	shelter_panel.visible = false
	if extra_shelter_panel:
		extra_shelter_panel.visible = false
	garrison_panel.visible = not garrison_panel.visible
	if garrison_panel.visible:
		garrison_soldier_label.text = "%d / 5" % soldiers_in_garrison

func _on_generals_quarters_tapped():
	_show_building_info(generals_quarters, "General's Quarters\nMarcus the Iron Fist rests here\nbetween crusades.")

func _on_soldier_arrived_at_garrison():
	if training_node:
		soldiers_in_garrison += 1
		soldier_waiting_at_armory = false
		training_node.needs_shelter = false
		training_node.start_wandering(
			garrison.position + Vector2(randf_range(-35, 35), 80 + randf_range(-8, 8)))
		training_node = null
	_reset_training_ui()

func _on_train_pressed():
	if training or training_node != null or believers_count <= 1:
		return
	var chosen: CharacterBody2D = null
	for b in believers:
		chosen = b
		break
	if chosen == null:
		return
	believers.erase(chosen)
	training_node = chosen
	training = true
	training_timer = TRAINING_TIME
	# Step 1: walk down to shelter exit (onto the road, below the building)
	# Step 2: follow road north to barracks Y, then horizontal into barracks door
	var shelter_exit := SHELTER_POS + Vector2(0, 80)
	var armory_door  := armory.position + Vector2(0, 20)
	chosen.walk_to(shelter_exit)
	chosen.reached_forced_target.connect(func():
		_walk_via_road(chosen, shelter_exit, armory_door, _on_believer_arrived_at_armory)
	, CONNECT_ONE_SHOT)
	_update_training_ui()

func _on_believer_arrived_at_armory():
	if training_node:
		training_node.visible = false
		training_node.park()

func _on_training_rush_pressed():
	if faith < 1:
		return
	faith -= 1
	training_timer = max(0.0, training_timer - 600.0)
	if training_timer <= 0.0:
		_complete_training()
	else:
		_update_training_ui()

func _complete_training():
	training = false
	believers_count -= 1
	soldiers_count += 1
	if training_node:
		training_node.convert_to_soldier()
		soldiers.append(training_node)
		if garrison_built and garrison != null:
			training_node.visible = true
			_walk_via_road(training_node, armory.position + Vector2(0, 20), garrison.position + Vector2(randf_range(-15, 15), 48), _on_soldier_arrived_at_garrison)
		else:
			# No garrison yet — stand at barracks door and wait
			soldier_waiting_at_armory = true
			training_node.visible = true
			training_node.position = armory.position + Vector2(0, 30)
			training_node.needs_shelter = true
			training_node.park()
	_reset_training_ui()

func _update_training_ui():
	var mins := int(training_timer) / 60
	var secs := int(training_timer) % 60
	training_label.text = "Training — %d:%02d remaining" % [mins, secs]
	train_btn.disabled = true
	train_btn.text = "Training… (%d:%02d)" % [mins, secs]
	var progress := 1.0 - (training_timer / TRAINING_TIME)
	training_bar.anchor_right = progress
	training_rush_btn.visible = true
	training_rush_btn.disabled = faith < 1
	training_rush_btn.text = "⚡ -10m" if faith >= 1 else "⚡ need Faith"

func _reset_training_ui():
	if soldier_waiting_at_armory:
		training_label.text = "⚠  Soldier waiting — build a Garrison!"
		train_btn.disabled = true
		train_btn.text = "Soldier needs a home first"
	elif believers_count <= 1:
		training_label.text = "Need at least 2 believers to train"
		train_btn.disabled = true
		train_btn.text = "Train Soldier  (30 min)"
	else:
		training_label.text = "Ready to train"
		train_btn.disabled = false
		train_btn.text = "Train Soldier  (30 min)"
	training_bar.anchor_right = 0.0
	training_rush_btn.visible = false


# ── Placement input + map panning ────────────────────────────────────────────
func _zoom_camera(screen_pivot: Vector2, direction: int):
	if camera_controller == null:
		return
	camera_controller.zoom(screen_pivot, get_viewport().get_visible_rect().size, direction)


# Use _input (not _unhandled_input) so Control nodes eating mouse events don't block us
func _input(event: InputEvent):
	# Map panning: right-click drag — divide by zoom so pan speed feels consistent
	if event is InputEventMouseMotion and camera_controller != null and camera_controller.is_panning:
		camera_controller.update_pan(event.position)
		get_viewport().set_input_as_handled()
		return

	# Scroll-wheel zoom
	var mb_early := event as InputEventMouseButton
	if mb_early != null and mb_early.pressed and \
			mb_early.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		_zoom_camera(mb_early.position, 1 if mb_early.button_index == MOUSE_BUTTON_WHEEL_UP else -1)
		get_viewport().set_input_as_handled()
		return

	# R key rotates corner/T road tiles during placement
	var key := event as InputEventKey
	if key != null and key.pressed and placing_road:
		if key.keycode == KEY_R:
			_on_road_rotate()
			get_viewport().set_input_as_handled()
		return

	var mb := event as InputEventMouseButton
	if mb == null:
		return

	# Road placement: left-click places a tile, right-click cancels
	if placing_road:
		if mb.pressed and mb.button_index == MOUSE_BUTTON_RIGHT:
			get_viewport().set_input_as_handled()
			_cancel_road_placement()
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			var road_pos := get_viewport().get_canvas_transform().affine_inverse() \
				* get_viewport().get_mouse_position()
			get_viewport().set_input_as_handled()
			_place_road_tile(road_pos)
		return

	if mb.button_index == MOUSE_BUTTON_RIGHT:
		if mb.pressed:
			if placing_building:
				get_viewport().set_input_as_handled()
				_cancel_placement()
			else:
				if camera_controller != null:
					camera_controller.start_pan(mb.position)
		else:
			if camera_controller != null:
				camera_controller.stop_pan()
		return

	if not placing_building:
		return
	if not mb.pressed:
		return

	var vp_size := get_viewport().get_visible_rect().size
	var screen_pos: Vector2 = mb.position

	# Ignore clicks on the top UI bar or the bottom tutorial/construction strip
	if screen_pos.y < 58 or screen_pos.y > vp_size.y - 60:
		return

	if mb.button_index == MOUSE_BUTTON_LEFT:
		var pos := get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
		if _can_place_here(pos):
			get_viewport().set_input_as_handled()
			_place_building(pos)
		else:
			# Warn the player, then restore after 2 seconds
			tutorial_label.text = "Can't build there! Too close to a tree or building."
			get_tree().create_timer(2.0).timeout.connect(_update_tutorial)


func _can_place_here(pos: Vector2) -> bool:
	for zone in blocked_zones:
		if pos.distance_to(zone["pos"]) < zone["radius"]:
			return false
	return true


func _on_wheel_chip_input(event: InputEvent):
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if tut_step == TutStep.WHEEL_HINT:
		tut_step = TutStep.DONE
		_update_tutorial()
	if wheel_popup != null:
		wheel_popup.open(wheel_available)


func _build_wheel_popup(ui: CanvasLayer):
	wheel_popup = WHEEL_POPUP_SCENE.instantiate()
	ui.add_child(wheel_popup)
	wheel_popup.spin_pressed.connect(_on_spin_pressed)
	wheel_popup.spin_finished.connect(_complete_spin)


func _on_spin_pressed():
	if wheel_spinning or not wheel_available:
		return
	wheel_spinning = true
	wheel_available = false
	wheel_daily_timer = 0.0
	if wheel_chip_node != null:
		wheel_chip_node.visible = false

	# First spin always lands on +100 Gold (segment 2), after that random
	var target_seg: int = WheelOfFaithScript.pick_segment(is_first_spin)
	is_first_spin = false
	wheel_popup.start_spin(target_seg)


func _complete_spin(seg_index: int):
	wheel_spinning = false
	var result: Dictionary = WheelOfFaithScript.apply_reward(seg_index, gold, faith)
	gold = result.gold
	faith = result.faith
	_refresh_resource_labels()

	wheel_popup.show_result(result.text)


# ── Resource display ──────────────────────────────────────────────────────────
func _refresh_resource_labels():
	gold_label.text      = "Gold  %d"   % gold
	faith_label.text     = "Faith  %d"  % faith
	var total_people := believers_count + preachers_count + soldiers_count
	believers_label.text = "People  %d" % total_people
	# Keep people popup fresh while it's open
	if people_panel != null and people_panel.visible:
		_refresh_people_panel()

# ── Crusade functions ─────────────────────────────────────────────────────────

func _on_crusade_pressed():
	if crusading or soldiers_in_garrison <= 0:
		return
	crusade_selector_count = mini(1, soldiers_in_garrison)
	_update_crusade_selector_label()
	crusade_go_btn.visible = false
	crusade_selector_row.visible = true
	# Show Marcus toggle only when he's available and at his quarters
	if crusade_bring_marcus_btn != null:
		crusade_bring_marcus_btn.visible = generals_quarters_built and marcus_obtained and not marcus_leading_crusade
		crusade_bring_marcus_btn.button_pressed = false


func _update_crusade_selector_label():
	var s := "s" if crusade_selector_count != 1 else ""
	crusade_selector_label.text = "%d soldier%s" % [crusade_selector_count, s]


func _on_crusade_confirm_pressed():
	if crusading or crusade_selector_count <= 0 or soldiers_in_garrison < crusade_selector_count:
		return
	crusading = true
	crusade_sent = crusade_selector_count
	soldiers_in_garrison -= crusade_sent
	garrison_soldier_label.text = "%d / 5" % soldiers_in_garrison

	# Hide soldiers visually during crusade
	var hidden: int = 0
	for sol in soldiers:
		if hidden >= crusade_sent:
			break
		if is_instance_valid(sol):
			sol.visible = false
			crusading_nodes.append(sol)
			hidden += 1

	# If Marcus is toggled as leader, hide him from his quarters
	marcus_leading_crusade = crusade_bring_marcus_btn != null and crusade_bring_marcus_btn.button_pressed
	if marcus_leading_crusade and is_instance_valid(marcus_character_node):
		marcus_character_node.visible = false
		marcus_character_node.park()

	crusade_timer = CRUSADE_TIME
	crusade_selector_row.visible = false
	if crusade_bring_marcus_btn != null:
		crusade_bring_marcus_btn.visible = false
	crusade_progress_container.visible = true
	_update_crusade_ui()


func _update_crusade_ui():
	var mins: int = int(crusade_timer / 60.0)
	var secs: int = int(crusade_timer) % 60
	crusade_timer_label.text = "Crusading... %d:%02d remaining" % [mins, secs]
	var fill: float = 1.0 - (crusade_timer / CRUSADE_TIME)
	crusade_bar.anchor_right = fill
	if crusade_rush_btn != null:
		crusade_rush_btn.disabled = faith < 1


func _on_crusade_rush_pressed():
	if faith < 1:
		return
	faith -= 1
	crusade_timer = max(0.0, crusade_timer - 600.0)
	if crusade_timer <= 0.0:
		_complete_crusade()
	else:
		_update_crusade_ui()
	_refresh_resource_labels()


func _complete_crusade():
	crusading = false
	crusade_progress_container.visible = false
	crusade_go_btn.visible = true
	var led_by_marcus: bool = marcus_leading_crusade

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	# Marcus bonus: lower death rate + better boxes
	var death_rate := 0.05 if led_by_marcus else 0.15

	# Soldier casualties
	var survivors: int = 0
	for i in range(crusade_sent):
		if rng.randf() > death_rate:
			survivors += 1
	var fallen: int = crusade_sent - survivors
	soldiers_in_garrison += survivors

	# Return surviving soldiers visually
	var returned: int = 0
	for sol in crusading_nodes:
		if is_instance_valid(sol):
			if returned < survivors:
				sol.visible = true
				if garrison != null:
					sol.start_wandering(garrison.position + Vector2(rng.randf_range(-35, 35), rng.randf_range(-18, 18)))
				returned += 1
	crusading_nodes.clear()
	garrison_soldier_label.text = "%d / 5" % soldiers_in_garrison

	# Roll one treasure box per soldier sent
	var boxes: Array = []
	var total_gold: int = 0
	var total_faith: int = 0
	var got_marcus: bool = false

	for i in range(crusade_sent):
		var box: Dictionary = CrusadeRewardsScript.roll_box(rng)
		# Marcus leadership bonus: upgrade each box one rarity tier
		if led_by_marcus:
			box = CrusadeRewardsScript.upgrade_box_rarity(box, rng)
		boxes.append(box)
		total_gold  += box.gold
		total_faith += box.faith
		if not marcus_obtained and (true or rng.randf() < box.hero_chance):  # DEBUG: always drop on first crusade
			got_marcus = true

	if got_marcus:
		marcus_obtained = true

	# Return Marcus to his quarters
	if led_by_marcus:
		marcus_leading_crusade = false
		if is_instance_valid(marcus_character_node) and generals_quarters != null:
			marcus_character_node.visible = true
			marcus_character_node.start_wandering(generals_quarters.position + Vector2(0, 20))

	crusade_result_popup.open_result({
		"title": "Marcus Leads a Victory!" if led_by_marcus else "The Crusade Returns!",
		"fallen": fallen,
		"gold": total_gold,
		"faith": total_faith,
		"got_marcus": got_marcus,
		"boxes": boxes
	})


func _on_crusade_rewards_revealed(reward_gold: int, reward_faith: int, _got_marcus: bool) -> void:
	gold += reward_gold
	faith += reward_faith
	_refresh_resource_labels()

	if marcus_obtained:
		if build_menu != null:
			build_menu.set_generals_quarters_unlocked(true)
		if hero_deck_chip != null:
			hero_deck_chip.visible = true


# ── Crusade result popup ───────────────────────────────────────────────────────

func _build_crusade_result_popup(ui: CanvasLayer):
	crusade_result_popup = CRUSADE_RESULT_POPUP_SCENE.instantiate()
	ui.add_child(crusade_result_popup)
	crusade_result_popup.rewards_revealed.connect(_on_crusade_rewards_revealed)


# ── Hero Deck panel ────────────────────────────────────────────────────────────

func _build_hero_deck_panel(ui: CanvasLayer):
	hero_deck_panel = HERO_DECK_PANEL_SCENE.instantiate()
	ui.add_child(hero_deck_panel)


func _on_hero_deck_chip_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		hero_deck_panel.toggle_panel()


func _on_campaign_chip_input(event: InputEvent) -> void:
	if campaign_navigation_controller != null and campaign_navigation_controller.is_left_click(event):
		campaign_navigation_controller.start_new_campaign(self)


func _on_return_mission_input(event: InputEvent) -> void:
	if campaign_navigation_controller != null and campaign_navigation_controller.is_left_click(event):
		campaign_navigation_controller.return_to_active_campaign(self)
