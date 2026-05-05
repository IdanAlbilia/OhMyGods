class_name CrusadeResultPopup
extends ColorRect

signal rewards_revealed(gold: int, faith: int, got_marcus: bool)

const CrusadeRewardsScript: GDScript = preload("res://scripts/systems/crusade_rewards.gd")

@onready var _title_label: Label = %TitleLabel
@onready var _casualty_label: Label = %CasualtyLabel
@onready var _phase1: Control = %ChestPhase
@onready var _phase2: Control = %RewardsPhase
@onready var _chests_row: HBoxContainer = %ChestsRow
@onready var _rewards_label: Label = %RewardsLabel
@onready var _marcus_container: Control = %MarcusContainer
@onready var _open_button: Button = %OpenButton
@onready var _dismiss_button: Button = %DismissButton

var _chest_images: Array = []
var _pending_result: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	mouse_filter = Control.MOUSE_FILTER_STOP
	get_viewport().size_changed.connect(_fit_to_viewport)
	_open_button.pressed.connect(_on_open_chests_pressed)
	_dismiss_button.pressed.connect(func(): visible = false)
	_fit_to_viewport()
	visible = false


func open_result(result: Dictionary) -> void:
	_fit_to_viewport()
	_pending_result = result.duplicate(true)
	_title_label.text = str(result.get("title", "The Crusade Returns!"))
	_casualty_label.text = _casualty_text(int(result.get("fallen", 0)))
	_populate_chests(result.get("boxes", []))
	_phase1.visible = true
	_phase2.visible = false
	visible = true


func _fit_to_viewport() -> void:
	if not is_inside_tree():
		return
	position = Vector2.ZERO
	size = get_viewport_rect().size


func _casualty_text(fallen: int) -> String:
	if fallen <= 0:
		return "All soldiers returned safely!"
	var sf := "s" if fallen != 1 else ""
	return "%d soldier%s fell in battle." % [fallen, sf]


func _populate_chests(boxes: Array) -> void:
	for child in _chests_row.get_children():
		child.queue_free()
	_chest_images.clear()

	for box_data in boxes:
		_add_chest_box(str(box_data.rarity))


func _add_chest_box(rarity: String) -> void:
	var col: Color = CrusadeRewardsScript.rarity_color(rarity)

	var inner := VBoxContainer.new()
	inner.layout_direction = Control.LAYOUT_DIRECTION_LTR
	inner.add_theme_constant_override("separation", 4)
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_chests_row.add_child(inner)

	var chest_tex: Texture2D = load("res://assets/ui/Treasure box.png")
	var img := TextureRect.new()
	img.layout_direction = Control.LAYOUT_DIRECTION_LTR
	img.texture = chest_tex
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.custom_minimum_size = Vector2(220, 220)
	img.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	img.modulate = col.lightened(0.15) if rarity != "Common" else Color.WHITE
	inner.add_child(img)
	_chest_images.append(img)

	var rar_lbl := Label.new()
	rar_lbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	rar_lbl.text = rarity
	rar_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rar_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rar_lbl.add_theme_font_size_override("font_size", 14)
	rar_lbl.add_theme_color_override("font_color", col)
	inner.add_child(rar_lbl)


func _on_open_chests_pressed() -> void:
	var open_tex: Texture2D = load("res://assets/ui/Open Treasure Box.png")
	var total: int = _chest_images.size()

	for i in total:
		var img: TextureRect = _chest_images[i]
		var delay: float = i * 0.18
		var tw: Tween = create_tween()
		tw.tween_interval(delay)
		tw.tween_property(img, "scale", Vector2(1.25, 1.25), 0.10)
		tw.tween_callback(func():
			img.texture = open_tex
			img.modulate = Color.WHITE
		)
		tw.tween_property(img, "scale", Vector2(1.0, 1.0), 0.12)

	var switch_delay: float = total * 0.18 + 0.45
	var sw: Tween = create_tween()
	sw.tween_interval(switch_delay)
	sw.tween_callback(_show_rewards_phase)


func _show_rewards_phase() -> void:
	var g: int = int(_pending_result.get("gold", 0))
	var f: int = int(_pending_result.get("faith", 0))
	var got_marcus: bool = bool(_pending_result.get("got_marcus", false))

	_rewards_label.text = "+%d Gold     +%d Faith" % [g, f]
	_marcus_container.visible = got_marcus
	_phase1.visible = false
	_phase2.visible = true
	rewards_revealed.emit(g, f, got_marcus)
