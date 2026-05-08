class_name PeoplePanelFactory


static func build(ui: CanvasLayer) -> Dictionary:
	var panel := PanelContainer.new()
	panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	panel.anchor_left = 0.0
	panel.anchor_right = 0.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = 6
	panel.offset_top = 58
	panel.offset_right = 220
	panel.offset_bottom = 130
	panel.visible = false
	ui.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title := Label.new()
	title.layout_direction = Control.LAYOUT_DIRECTION_LTR
	title.text = "Your People"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.40))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var detail_label := Label.new()
	detail_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	detail_label.add_theme_font_size_override("font_size", 13)
	detail_label.add_theme_color_override("font_color", Color(0.90, 0.90, 0.90))
	vbox.add_child(detail_label)

	return {
		"panel": panel,
		"detail_label": detail_label,
	}
