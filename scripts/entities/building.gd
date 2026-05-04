extends StaticBody2D

@export var building_type: String = "shelter"
@export var building_label: String = ""
@export var is_interactive: bool = false

signal tapped

# Sprite2D is supplied by each building scene, so visuals stay prefab-owned.
var _sprite: Sprite2D = null

func _ready():
	input_pickable = true
	_sprite = get_node_or_null("Sprite2D") as Sprite2D
	_ensure_collision_shape()
	input_event.connect(_on_input_event)


func _ensure_collision_shape():
	for child in get_children():
		if child is CollisionShape2D:
			return

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(100, 70)
	shape.position = Vector2(0, -52)
	shape.shape = rect
	add_child(shape)


func _on_input_event(_viewport, event, _shape_idx):
	if is_interactive and event is InputEventMouseButton:
		if event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
			tapped.emit()


func _draw():
	if _sprite != null:
		_sprite.visible = true
		_sprite.modulate = Color(0.60, 1.0, 0.60, 0.55) if has_meta("under_construction") else Color.WHITE
