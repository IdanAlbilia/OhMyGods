class_name TutorialPanelFactory
extends RefCounted


static func build(ui: CanvasLayer, leader_name: String, selected_leader: int, ok_pressed: Callable) -> Dictionary:
	var refs := {}

	var overlay := ColorRect.new()
	overlay.layout_direction = Control.LAYOUT_DIRECTION_LTR
	overlay.anchor_left = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_top = 0.0
	overlay.anchor_bottom = 1.0
	overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	ui.add_child(overlay)
	refs["overlay"] = overlay

	var popup := PanelContainer.new()
	popup.layout_direction = Control.LAYOUT_DIRECTION_LTR
	popup.anchor_left = 0.5
	popup.anchor_right = 0.5
	popup.anchor_top = 0.5
	popup.anchor_bottom = 0.5
	popup.offset_left = -235
	popup.offset_right = 235
	popup.offset_top = -115
	popup.offset_bottom = 115
	popup.add_theme_stylebox_override("panel", _popup_style())
	popup.visible = false
	ui.add_child(popup)
	refs["popup"] = popup

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	popup.add_child(hbox)

	var portrait_frame := Control.new()
	portrait_frame.custom_minimum_size = Vector2(100, 150)
	portrait_frame.clip_contents = true
	portrait_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(portrait_frame)

	var portrait := TextureRect.new()
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = load(_portrait_path(selected_leader))
	portrait_frame.add_child(portrait)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	hbox.add_child(vbox)

	var name_label := Label.new()
	name_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	name_label.text = leader_name
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.25))
	vbox.add_child(name_label)

	var popup_text := Label.new()
	popup_text.layout_direction = Control.LAYOUT_DIRECTION_LTR
	popup_text.text = ""
	popup_text.add_theme_font_size_override("font_size", 14)
	popup_text.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))
	popup_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(popup_text)
	refs["popup_text"] = popup_text

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(btn_row)

	var ok_btn := Button.new()
	ok_btn.text = "OK"
	ok_btn.custom_minimum_size = Vector2(80, 36)
	ok_btn.pressed.connect(ok_pressed)
	btn_row.add_child(ok_btn)

	refs["shelter_arrow"] = _build_shelter_arrow(ui)
	refs["shelter_arrow_label"] = refs["shelter_arrow"].get_child(0)
	refs["rush_arrow"] = _build_rush_arrow(ui)
	refs["wheel_arrow"] = _build_wheel_arrow(ui)
	refs["toast_label"] = _build_toast_label(ui)

	return refs


static func _popup_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.16, 0.97)
	style.border_color = Color(0.85, 0.68, 0.15)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style


static func _portrait_path(selected_leader: int) -> String:
	match selected_leader:
		0:
			return "res://assets/characters/leaders/High Priest.png"
		1:
			return "res://assets/characters/leaders/Prophet of Wealth.png"
		2:
			return "res://assets/characters/leaders/Holy General.png"
	return "res://assets/characters/leaders/High Priest.png"


static func _build_shelter_arrow(ui: CanvasLayer) -> PanelContainer:
	var arrow := PanelContainer.new()
	arrow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	arrow.anchor_left = 0.0
	arrow.anchor_right = 0.0
	arrow.anchor_top = 0.0
	arrow.anchor_bottom = 0.0
	arrow.offset_left = 0
	arrow.offset_right = 180
	arrow.offset_top = 0
	arrow.offset_bottom = 36

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.04, 0.10, 0.88)
	style.border_color = Color(0.95, 0.15, 0.15)
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	arrow.add_theme_stylebox_override("panel", style)
	arrow.visible = false
	ui.add_child(arrow)

	var label := Label.new()
	label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	label.text = "↓  Tap Shelter"
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.95, 0.15, 0.15))
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow.add_child(label)
	return arrow


static func _build_rush_arrow(ui: CanvasLayer) -> Label:
	var arrow := Label.new()
	arrow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	arrow.text = "Tap Rush →"
	arrow.add_theme_font_size_override("font_size", 14)
	arrow.add_theme_color_override("font_color", Color(1.0, 0.30, 0.30))
	arrow.anchor_left = 0.0
	arrow.anchor_right = 0.0
	arrow.anchor_top = 1.0
	arrow.anchor_bottom = 1.0
	arrow.offset_left = 16
	arrow.offset_right = 160
	arrow.offset_top = -82
	arrow.offset_bottom = -60
	arrow.visible = false
	ui.add_child(arrow)
	return arrow


static func _build_wheel_arrow(ui: CanvasLayer) -> PanelContainer:
	var arrow := PanelContainer.new()
	arrow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	arrow.anchor_left = 0.0
	arrow.anchor_right = 0.0
	arrow.anchor_top = 0.0
	arrow.anchor_bottom = 0.0
	arrow.offset_top = 58
	arrow.offset_bottom = 94

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.04, 0.10, 0.90)
	style.border_color = Color(0.95, 0.15, 0.15)
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	arrow.add_theme_stylebox_override("panel", style)
	arrow.visible = false

	var label := Label.new()
	label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	label.text = "↑  Tap to Spin!"
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.95, 0.15, 0.15))
	arrow.add_child(label)
	ui.add_child(arrow)
	return arrow


static func _build_toast_label(ui: CanvasLayer) -> Label:
	var label := Label.new()
	label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	label.offset_top = 52
	label.offset_bottom = 80
	label.offset_left = -300
	label.offset_right = 300
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1.0, 0.30, 0.20))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.text = ""
	ui.add_child(label)
	return label
