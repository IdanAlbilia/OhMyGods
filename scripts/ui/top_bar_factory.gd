class_name TopBarFactory


static func build(
	ui: CanvasLayer,
	wheel_available: bool,
	mission_active: bool,
	people_input: Callable,
	wheel_input: Callable,
	hero_deck_input: Callable,
	campaign_input: Callable,
	return_mission_input: Callable
) -> Dictionary:
	var bar := ColorRect.new()
	bar.color = Color(0.08, 0.06, 0.12, 0.92)
	bar.size = Vector2(1152, 54)
	bar.position = Vector2.ZERO
	ui.add_child(bar)

	var hbox := HBoxContainer.new()
	hbox.layout_direction = Control.LAYOUT_DIRECTION_LTR
	hbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	hbox.offset_left = 10
	hbox.offset_top = 6
	hbox.add_theme_constant_override("separation", 6)
	ui.add_child(hbox)

	var believers_chip := _resource_chip(Color(0.30, 0.80, 0.35), Color(0.14, 0.45, 0.18))
	var people_chip_node: PanelContainer = believers_chip["chip"]
	people_chip_node.mouse_filter = Control.MOUSE_FILTER_STOP
	people_chip_node.gui_input.connect(people_input)
	hbox.add_child(people_chip_node)

	var faith_chip := _resource_chip(Color(0.72, 0.55, 1.00), Color(0.38, 0.20, 0.65))
	hbox.add_child(faith_chip["chip"])

	var gold_chip := _resource_chip(Color(1.00, 0.82, 0.15), Color(0.65, 0.45, 0.05))
	hbox.add_child(gold_chip["chip"])

	var wheel_chip := _action_chip(
		"✦ Spin",
		Color(0.45, 0.30, 0.05),
		Color(0.95, 0.75, 0.10),
		Color(0.98, 0.88, 0.30),
		wheel_input
	)
	wheel_chip.visible = wheel_available
	hbox.add_child(wheel_chip)

	var hero_deck_chip := _action_chip(
		"🃏 Heroes",
		Color(0.55, 0.35, 0.05, 0.90),
		Color(0.95, 0.75, 0.20),
		Color(0.98, 0.88, 0.30),
		hero_deck_input,
		1
	)
	hero_deck_chip.visible = false
	hbox.add_child(hero_deck_chip)

	var campaign_chip := _action_chip(
		"⚔ Mission",
		Color(0.18, 0.36, 0.16),
		Color(0.42, 0.72, 0.28),
		Color(0.72, 1.00, 0.52),
		campaign_input
	)
	campaign_chip.visible = not mission_active
	hbox.add_child(campaign_chip)

	var return_mission_chip := _action_chip(
		"▶ Mission",
		Color(0.42, 0.14, 0.06),
		Color(1.0, 0.45, 0.18),
		Color(1.0, 0.65, 0.35),
		return_mission_input
	)
	return_mission_chip.visible = mission_active
	hbox.add_child(return_mission_chip)

	return {
		"believers_label": believers_chip["label"],
		"faith_label": faith_chip["label"],
		"gold_label": gold_chip["label"],
		"wheel_chip": wheel_chip,
		"hero_deck_chip": hero_deck_chip,
		"campaign_chip": campaign_chip,
		"return_mission_chip": return_mission_chip,
	}


static func _resource_chip(light: Color, dark: Color) -> Dictionary:
	var chip := PanelContainer.new()
	chip.layout_direction = Control.LAYOUT_DIRECTION_LTR

	var style := StyleBoxFlat.new()
	style.bg_color = dark.darkened(0.25)
	style.border_color = dark
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 6
	style.content_margin_right = 10
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	chip.add_theme_stylebox_override("panel", style)

	var row := HBoxContainer.new()
	row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	row.add_theme_constant_override("separation", 5)
	chip.add_child(row)

	var dot_node := ColorRect.new()
	dot_node.color = light
	dot_node.custom_minimum_size = Vector2(14, 14)
	dot_node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot_node)

	var lbl := Label.new()
	lbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	lbl.add_theme_font_size_override("font_size", 17)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)

	return {"label": lbl, "chip": chip}


static func _action_chip(
	text: String,
	background: Color,
	border: Color,
	font_color: Color,
	input_callback: Callable,
	border_width: int = 2
) -> PanelContainer:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4

	var chip := PanelContainer.new()
	chip.layout_direction = Control.LAYOUT_DIRECTION_LTR
	chip.add_theme_stylebox_override("panel", style)
	chip.mouse_filter = Control.MOUSE_FILTER_STOP

	var lbl := Label.new()
	lbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", font_color)
	chip.add_child(lbl)

	chip.gui_input.connect(input_callback)
	return chip
