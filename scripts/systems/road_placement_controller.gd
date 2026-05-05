class_name RoadPlacementController
extends RefCounted

const RoadTilesScript: GDScript = preload("res://scripts/systems/road_tiles.gd")

var active: bool = false
var road_type: String = ""
var rotation_deg: int = 0
var ghost_sprite: Sprite2D = null
var rotate_button: Button = null
var placed_tiles: Array = []


func setup_rotate_button(ui: CanvasLayer, rotate_callback: Callable) -> Button:
	rotate_button = Button.new()
	rotate_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	rotate_button.text = "↻  Rotate"
	rotate_button.add_theme_font_size_override("font_size", 15)
	rotate_button.add_theme_color_override("font_color", Color(1.0, 0.92, 0.28))
	rotate_button.anchor_left = 0.5
	rotate_button.anchor_right = 0.5
	rotate_button.anchor_top = 1.0
	rotate_button.anchor_bottom = 1.0
	rotate_button.offset_left = -70
	rotate_button.offset_right = 70
	rotate_button.offset_top = -130
	rotate_button.offset_bottom = -95
	rotate_button.visible = false
	rotate_button.pressed.connect(rotate_callback)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.35, 0.24, 0.06)
	style.border_color = Color(0.72, 0.54, 0.16)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.content_margin_left = 16
	style.content_margin_right = 16
	rotate_button.add_theme_stylebox_override("normal", style)

	ui.add_child(rotate_button)
	return rotate_button


func rotate() -> void:
	rotation_deg = (rotation_deg + 90) % 360
	if ghost_sprite != null:
		ghost_sprite.rotation_degrees = float(rotation_deg)


func start(type: String, world: Node2D, mouse_pos: Vector2) -> void:
	active = true
	road_type = type
	rotation_deg = 0

	ghost_sprite = RoadTilesScript.make_sprite(type, mouse_pos, rotation_deg)
	ghost_sprite.modulate = Color(0.60, 1.0, 0.60, 0.55)
	world.add_child(ghost_sprite)

	if rotate_button != null:
		rotate_button.visible = RoadTilesScript.is_rotatable(type)


func cancel() -> void:
	active = false
	road_type = ""
	rotation_deg = 0

	if ghost_sprite != null:
		ghost_sprite.queue_free()
		ghost_sprite = null

	if rotate_button != null:
		rotate_button.visible = false


func update_ghost_position(pos: Vector2) -> void:
	if active and ghost_sprite != null:
		ghost_sprite.position = pos


func place(world: Node2D, pos: Vector2) -> void:
	var spr: Sprite2D = RoadTilesScript.make_sprite(road_type, pos, rotation_deg)
	world.add_child(spr)
	world.move_child(spr, 1)

	placed_tiles.append({
		"type": road_type,
		"position": pos,
		"rotation": rotation_deg,
	})
