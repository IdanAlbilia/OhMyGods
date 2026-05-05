class_name BuildMenu
extends PanelContainer

signal build_requested(type: String, cost: int)
signal road_requested(type: String)

@onready var _close_button: Button = %CloseButton
@onready var _generals_row: Control = %GeneralsRow
@onready var _generals_sep: Control = %GeneralsSep
@onready var _temple_hint: Label = %TempleHint
@onready var _list: VBoxContainer = $Outer/Scroll/List

const MENU_MARGIN := 8.0
const MENU_TOP := 62.0
const MENU_MAX_WIDTH := 362.0
const MENU_MAX_HEIGHT := 498.0
const MENU_BOTTOM_RESERVE := 64.0

const ROW_ICONS := {
	"TempleRow": "res://assets/buildings/Comp6.png",
	"ShelterRow": "res://assets/buildings/Comp1.png",
	"HallRow": "res://assets/buildings/Comp5.png",
	"PreacherShelterRow": "res://assets/buildings/Comp2.png",
	"ArmoryRow": "res://assets/buildings/Comp4.png",
	"GarrisonRow": "res://assets/buildings/Comp3.png",
	"GeneralsRow": "res://assets/characters/marcus/Marcus Habitat.png",
	"WellRow": "res://assets/buildings/Comp8.png",
	"GardenRow": "res://assets/buildings/Comp7.png",
	"StonePoolRow": "res://assets/buildings/Comp10.png",
	"RoadHRow": "res://assets/roads/Comp_14- no bg.png",
	"RoadVRow": "res://assets/roads/Comp_13- no bg.png",
	"RoadCornerRow": "res://assets/roads/Comp_12- no bg.png",
	"RoadTRow": "res://assets/roads/Comp_11- no bg.png",
}

const BUILD_BUTTONS := {
	"TempleButton": ["temple", 30],
	"ShelterButton": ["shelter", 40],
	"HallButton": ["hall_of_devoted", 70],
	"PreacherShelterButton": ["preacher_shelter", 50],
	"ArmoryButton": ["armory", 80],
	"GarrisonButton": ["garrison", 60],
	"GeneralsButton": ["generals_quarters", 100],
	"WellButton": ["well", 25],
	"GardenButton": ["garden", 30],
	"StonePoolButton": ["stone_pool", 35],
}

const ROAD_BUTTONS := {
	"RoadHButton": "road_h",
	"RoadVButton": "road_v",
	"RoadCornerButton": "road_corner",
	"RoadTButton": "road_t",
}


func _ready() -> void:
	visible = false
	layout_direction = Control.LAYOUT_DIRECTION_LTR
	_fit_to_viewport()
	get_viewport().size_changed.connect(_fit_to_viewport)
	_prepare_runtime_layout()
	_close_button.pressed.connect(hide_menu)
	_connect_build_buttons()
	_connect_road_buttons()
	set_generals_quarters_unlocked(false)


func toggle_menu() -> void:
	visible = not visible


func hide_menu() -> void:
	visible = false


func set_generals_quarters_unlocked(unlocked: bool) -> void:
	if _generals_row != null:
		_generals_row.visible = unlocked
	if _generals_sep != null:
		_generals_sep.visible = unlocked


func is_generals_quarters_unlocked() -> bool:
	return _generals_row != null and _generals_row.visible


func set_temple_hint_visible(is_visible: bool) -> void:
	if _temple_hint != null:
		_temple_hint.visible = is_visible


func is_temple_hint_visible() -> bool:
	return _temple_hint != null and _temple_hint.visible


func set_temple_hint_color(color: Color) -> void:
	if _temple_hint != null:
		_temple_hint.add_theme_color_override("font_color", color)


func _fit_to_viewport() -> void:
	if not is_inside_tree():
		return
	var viewport_size := get_viewport_rect().size
	var width: float = min(MENU_MAX_WIDTH, max(280.0, viewport_size.x - MENU_MARGIN * 2.0))
	var height: float = min(MENU_MAX_HEIGHT, max(280.0, viewport_size.y - MENU_TOP - MENU_BOTTOM_RESERVE - MENU_MARGIN))
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 0.0
	offset_right = -MENU_MARGIN
	offset_left = offset_right - width
	offset_top = MENU_TOP
	offset_bottom = MENU_TOP + height


func _prepare_runtime_layout() -> void:
	_set_ltr_recursive(self)
	_insert_section_header("BuildingsHeader", "BUILDINGS", 0)
	var road_sep := _list.get_node_or_null("RoadHSep")
	if road_sep != null:
		_insert_section_header("RoadsHeader", "ROADS", road_sep.get_index())

	for child in _list.get_children():
		if child is HBoxContainer:
			_prepare_row(child)

	for button_name in BUILD_BUTTONS.keys():
		_prepare_button(get_node("%" + button_name) as Button)
	for button_name in ROAD_BUTTONS.keys():
		_prepare_button(get_node("%" + button_name) as Button)

	if _temple_hint != null:
		_temple_hint.text = "< First"
		_temple_hint.custom_minimum_size = Vector2(44, 0)
		_temple_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func _set_ltr_recursive(node: Node) -> void:
	if node is Control:
		(node as Control).layout_direction = Control.LAYOUT_DIRECTION_LTR
	for child in node.get_children():
		_set_ltr_recursive(child)


func _insert_section_header(node_name: String, text: String, index: int) -> void:
	if _list.has_node(node_name):
		return
	var header := Label.new()
	header.name = node_name
	header.text = text
	header.custom_minimum_size = Vector2(0, 28)
	header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 12)
	header.add_theme_color_override("font_color", Color(1.0, 0.82, 0.25))
	_list.add_child(header)
	_list.move_child(header, index)


func _prepare_row(row: HBoxContainer) -> void:
	row.custom_minimum_size = Vector2(0, 46)
	row.add_theme_constant_override("separation", 8)
	_add_row_icon(row)
	for child in row.get_children():
		if child is Label:
			var label := child as Label
			label.clip_text = true
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			if label.name == "Cost":
				label.custom_minimum_size = Vector2(40, 0)
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			elif label.name == "Name":
				label.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _add_row_icon(row: HBoxContainer) -> void:
	if row.has_node("Icon"):
		return
	var texture_path: String = ROW_ICONS.get(row.name, "")
	if texture_path.is_empty():
		return
	var tex: Texture2D = load(texture_path)
	if tex == null:
		return
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.texture = tex
	icon.custom_minimum_size = Vector2(38, 38)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	row.move_child(icon, 0)


func _prepare_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(64, 30)
	button.size_flags_horizontal = Control.SIZE_SHRINK_END
	button.focus_mode = Control.FOCUS_NONE


func _connect_build_buttons() -> void:
	for button_name in BUILD_BUTTONS.keys():
		var button := get_node("%" + button_name) as Button
		var data: Array = BUILD_BUTTONS[button_name]
		button.pressed.connect(func():
			build_requested.emit(str(data[0]), int(data[1]))
		)


func _connect_road_buttons() -> void:
	for button_name in ROAD_BUTTONS.keys():
		var button := get_node("%" + button_name) as Button
		var road_type: String = ROAD_BUTTONS[button_name]
		button.pressed.connect(func():
			road_requested.emit(road_type)
		)
