class_name BuildingPanelFactory


static func make_panel(ui: CanvasLayer, accent: Color, title: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -358
	panel.offset_right = -8
	panel.offset_top = 62
	panel.offset_bottom = 310
	panel.visible = false

	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.07, 0.05, 0.12, 0.97)
	ps.border_color = accent
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(10)
	ps.content_margin_left = 0
	ps.content_margin_right = 0
	ps.content_margin_top = 0
	ps.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", ps)
	ui.add_child(panel)

	var outer := VBoxContainer.new()
	outer.layout_direction = Control.LAYOUT_DIRECTION_LTR
	outer.add_theme_constant_override("separation", 0)
	panel.add_child(outer)

	var tbar := ColorRect.new()
	tbar.color = accent.darkened(0.45)
	tbar.custom_minimum_size = Vector2(0, 40)
	outer.add_child(tbar)

	var trow := HBoxContainer.new()
	trow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	trow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tbar.add_child(trow)

	var tlbl := Label.new()
	tlbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	tlbl.text = "  " + title
	tlbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tlbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tlbl.add_theme_font_size_override("font_size", 15)
	tlbl.add_theme_color_override("font_color", accent.lightened(0.55))
	trow.add_child(tlbl)

	var close_x := Button.new()
	close_x.layout_direction = Control.LAYOUT_DIRECTION_LTR
	close_x.text = "✕"
	close_x.flat = true
	close_x.custom_minimum_size = Vector2(40, 40)
	close_x.add_theme_font_size_override("font_size", 16)
	close_x.add_theme_color_override("font_color", accent.lightened(0.40))
	close_x.pressed.connect(func(): panel.visible = false)
	trow.add_child(close_x)

	return panel


static func panel_body(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 0)
	panel.get_child(0).add_child(margin)

	var body := VBoxContainer.new()
	body.layout_direction = Control.LAYOUT_DIRECTION_LTR
	body.add_theme_constant_override("separation", 8)
	margin.add_child(body)
	return body


static func count_row(body: VBoxContainer, label_text: String, value_color: Color) -> Label:
	var row := HBoxContainer.new()
	row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	body.add_child(row)

	var lbl := Label.new()
	lbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	lbl.text = label_text + ":"
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.72, 0.70, 0.66))
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)

	var val := Label.new()
	val.layout_direction = Control.LAYOUT_DIRECTION_LTR
	val.text_direction = Control.TEXT_DIRECTION_LTR
	val.text = "0 / 5"
	val.add_theme_font_size_override("font_size", 16)
	val.add_theme_color_override("font_color", value_color)
	row.add_child(val)
	return val


static func panel_sep(body: VBoxContainer, accent: Color) -> void:
	var sep := ColorRect.new()
	sep.color = accent.darkened(0.40)
	sep.color.a = 0.45
	sep.custom_minimum_size = Vector2(0, 1)
	body.add_child(sep)


static func style_action_btn(btn: Button, accent: Color) -> void:
	btn.add_theme_font_size_override("font_size", 13)
	var s := StyleBoxFlat.new()
	s.bg_color = accent.darkened(0.45)
	s.border_color = accent
	s.set_border_width_all(1)
	s.set_corner_radius_all(5)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 7
	s.content_margin_bottom = 7
	btn.add_theme_stylebox_override("normal", s)

	var h := s.duplicate() as StyleBoxFlat
	h.bg_color = accent.darkened(0.20)
	btn.add_theme_stylebox_override("hover", h)

	var d := s.duplicate() as StyleBoxFlat
	d.bg_color = Color(0.12, 0.10, 0.18)
	d.border_color = accent.darkened(0.40)
	btn.add_theme_stylebox_override("disabled", d)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	btn.add_theme_color_override("font_disabled_color", Color(0.45, 0.43, 0.40))
