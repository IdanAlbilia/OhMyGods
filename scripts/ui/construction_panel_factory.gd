class_name ConstructionPanelFactory
extends RefCounted


static func build(ui: CanvasLayer, rush_pressed: Callable) -> Dictionary:
	var refs := {}

	var panel := PanelContainer.new()
	panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 8
	panel.offset_right = -8
	panel.offset_top = -155
	panel.offset_bottom = -48
	panel.visible = false
	panel.add_theme_stylebox_override("panel", _panel_style())
	ui.add_child(panel)
	refs["panel"] = panel

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 7)
	panel.add_child(vbox)

	var label := Label.new()
	label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	label.text = "Building — 5:00"
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.98, 0.84, 0.34))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(label)
	refs["label"] = label

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.06, 0.04, 0.01)
	bar_bg.custom_minimum_size = Vector2(0, 20)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(bar_bg)

	var bar := ColorRect.new()
	bar.color = Color(0.88, 0.62, 0.12)
	bar.anchor_top = 0.0
	bar.anchor_bottom = 1.0
	bar.anchor_left = 0.0
	bar.anchor_right = 0.0
	bar_bg.add_child(bar)
	refs["bar"] = bar

	var bar_shine := ColorRect.new()
	bar_shine.color = Color(1.0, 0.96, 0.55, 0.45)
	bar_shine.anchor_top = 0.0
	bar_shine.anchor_bottom = 0.0
	bar_shine.anchor_left = 0.0
	bar_shine.anchor_right = 1.0
	bar_shine.offset_top = 2
	bar_shine.offset_bottom = 7
	bar.add_child(bar_shine)

	var rush_button := Button.new()
	rush_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	rush_button.text = "⚡  Rush!  (1 Faith Point)"
	rush_button.add_theme_font_size_override("font_size", 14)
	rush_button.add_theme_color_override("font_color", Color(1.00, 0.92, 0.28))
	rush_button.add_theme_color_override("font_hover_color", Color(1.00, 0.98, 0.55))
	rush_button.add_theme_color_override("font_pressed_color", Color(0.90, 0.78, 0.18))
	rush_button.add_theme_color_override("font_disabled_color", Color(0.55, 0.44, 0.22))
	rush_button.pressed.connect(rush_pressed)
	_style_rush_button(rush_button)
	vbox.add_child(rush_button)
	refs["rush_button"] = rush_button

	return refs


static func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.05, 0.02, 0.95)
	style.border_color = Color(0.72, 0.54, 0.16)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.content_margin_left = 14
	style.content_margin_right = 14
	return style


static func _style_rush_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _button_style(Color(0.38, 0.22, 0.05), Color(0.78, 0.58, 0.16)))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.52, 0.32, 0.08), Color(0.95, 0.74, 0.24)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.25, 0.14, 0.03), Color(0.60, 0.44, 0.12)))
	button.add_theme_stylebox_override("disabled", _button_style(Color(0.18, 0.14, 0.08), Color(0.38, 0.30, 0.16)))


static func _button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	style.content_margin_left = 14
	style.content_margin_right = 14
	return style
