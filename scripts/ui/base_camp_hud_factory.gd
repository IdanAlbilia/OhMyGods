class_name BaseCampHudFactory
extends RefCounted


static func build_button(ui: CanvasLayer, pressed: Callable) -> Button:
	var button := Button.new()
	button.text = "Build"
	button.custom_minimum_size = Vector2(120, 44)
	button.add_theme_font_size_override("font_size", 18)
	button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = -130
	button.offset_top = -54
	button.offset_right = 0
	button.offset_bottom = 0
	button.pressed.connect(pressed)
	ui.add_child(button)
	return button


static func build_info_popup(ui: CanvasLayer) -> Dictionary:
	var refs := {}

	var panel := PanelContainer.new()
	panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	panel.visible = false
	ui.add_child(panel)
	refs["panel"] = panel

	var label := Label.new()
	label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.75))
	panel.add_child(label)
	refs["label"] = label

	return refs
