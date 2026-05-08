class_name MissionPanelFactory
extends RefCounted

const BuildingPanelFactoryScript: GDScript = preload("res://scripts/ui/building_panel_factory.gd")

const SPREAD_ACCENT := Color(0.30, 0.75, 0.72)
const SPREAD_COUNT_COLOR := Color(0.30, 0.82, 0.75)
const CRUSADE_ACCENT := Color(0.75, 0.22, 0.14)
const CRUSADE_COUNT_COLOR := Color(0.90, 0.55, 0.18)
const RUSH_ACCENT := Color(0.72, 0.55, 1.00)
const DISABLED_ACCENT := Color(0.50, 0.48, 0.44)


static func build_spread_panel(
	ui: CanvasLayer,
	go_pressed: Callable,
	minus_pressed: Callable,
	plus_pressed: Callable,
	confirm_pressed: Callable,
	rush_pressed: Callable
) -> Dictionary:
	var refs: Dictionary = _build_mission_panel(
		ui,
		"Preacher Shelter",
		"Preachers",
		SPREAD_ACCENT,
		SPREAD_COUNT_COLOR,
		"✉  Spread the Faith   (2 hr)",
		"Send →",
		"Spreading the faith...",
		Color(0.30, 0.90, 0.80),
		Color(0.10, 0.08, 0.16),
		Color(0.30, 0.82, 0.75),
		Vector2(0, 8),
		go_pressed,
		minus_pressed,
		plus_pressed,
		confirm_pressed,
		rush_pressed
	)
	var result_refs: Dictionary = _build_spread_result_popup(ui)
	refs["result_popup"] = result_refs["popup"]
	refs["result_label"] = result_refs["label"]
	return refs


static func build_crusade_panel(
	ui: CanvasLayer,
	go_pressed: Callable,
	minus_pressed: Callable,
	plus_pressed: Callable,
	confirm_pressed: Callable,
	rush_pressed: Callable
) -> Dictionary:
	var refs: Dictionary = _build_mission_panel(
		ui,
		"Garrison",
		"Soldiers housed",
		CRUSADE_ACCENT,
		CRUSADE_COUNT_COLOR,
		"⚔  Go on a Crusade   (2 hr)",
		"March →",
		"",
		Color(0.92, 0.90, 0.98),
		Color(0.18, 0.08, 0.08),
		Color(0.85, 0.25, 0.10),
		Vector2(0, 12),
		go_pressed,
		minus_pressed,
		plus_pressed,
		confirm_pressed,
		rush_pressed
	)

	var body: VBoxContainer = refs["body"]
	var marcus_button := Button.new()
	marcus_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	marcus_button.text = "⚔ Bring Marcus as Leader"
	marcus_button.toggle_mode = true
	marcus_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	marcus_button.visible = false
	BuildingPanelFactoryScript.style_action_btn(marcus_button, Color(0.80, 0.55, 0.10))
	body.add_child(marcus_button)
	body.move_child(marcus_button, refs["progress_container"].get_index())
	refs["marcus_button"] = marcus_button
	return refs


static func _build_mission_panel(
	ui: CanvasLayer,
	title: String,
	count_label_text: String,
	accent: Color,
	count_color: Color,
	go_text: String,
	confirm_text: String,
	progress_text: String,
	progress_text_color: Color,
	progress_bg_color: Color,
	progress_bar_color: Color,
	progress_bar_size: Vector2,
	go_pressed: Callable,
	minus_pressed: Callable,
	plus_pressed: Callable,
	confirm_pressed: Callable,
	rush_pressed: Callable
) -> Dictionary:
	var refs: Dictionary = {}
	var panel: PanelContainer = BuildingPanelFactoryScript.make_panel(ui, accent, title)
	refs["panel"] = panel

	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(panel)
	refs["body"] = body
	refs["count_label"] = BuildingPanelFactoryScript.count_row(body, count_label_text, count_color)
	BuildingPanelFactoryScript.panel_sep(body, accent)

	var go_button := Button.new()
	go_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	go_button.text = go_text
	go_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	BuildingPanelFactoryScript.style_action_btn(go_button, accent)
	go_button.pressed.connect(go_pressed)
	body.add_child(go_button)
	refs["go_button"] = go_button

	var selector_row := HBoxContainer.new()
	selector_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	selector_row.add_theme_constant_override("separation", 6)
	selector_row.visible = false
	body.add_child(selector_row)
	refs["selector_row"] = selector_row

	var minus_button := _selector_button("−", minus_pressed, 32)
	selector_row.add_child(minus_button)
	refs["minus_button"] = minus_button

	var selector_label := Label.new()
	selector_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	selector_label.text_direction = Control.TEXT_DIRECTION_LTR
	selector_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selector_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector_label.add_theme_font_size_override("font_size", 13)
	selector_row.add_child(selector_label)
	refs["selector_label"] = selector_label

	var plus_button := _selector_button("+", plus_pressed, 32)
	selector_row.add_child(plus_button)
	refs["plus_button"] = plus_button

	var confirm_button := Button.new()
	confirm_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	confirm_button.text = confirm_text
	BuildingPanelFactoryScript.style_action_btn(confirm_button, accent)
	confirm_button.pressed.connect(confirm_pressed)
	selector_row.add_child(confirm_button)
	refs["confirm_button"] = confirm_button

	var progress_container := VBoxContainer.new()
	progress_container.layout_direction = Control.LAYOUT_DIRECTION_LTR
	progress_container.add_theme_constant_override("separation", 6)
	progress_container.visible = false
	body.add_child(progress_container)
	refs["progress_container"] = progress_container

	var progress_label := Label.new()
	progress_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.text = progress_text
	progress_label.add_theme_font_size_override("font_size", 13)
	progress_label.add_theme_color_override("font_color", progress_text_color)
	progress_container.add_child(progress_label)
	refs["progress_label"] = progress_label

	var bar_bg := ColorRect.new()
	bar_bg.color = progress_bg_color
	bar_bg.custom_minimum_size = progress_bar_size
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_container.add_child(bar_bg)

	var progress_bar := ColorRect.new()
	progress_bar.color = progress_bar_color
	progress_bar.anchor_top = 0.0
	progress_bar.anchor_bottom = 1.0
	progress_bar.anchor_left = 0.0
	progress_bar.anchor_right = 0.0
	bar_bg.add_child(progress_bar)
	refs["progress_bar"] = progress_bar

	var rush_button := Button.new()
	rush_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	rush_button.text = "⚡ Rush  (1 Faith = -10 min)"
	rush_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	BuildingPanelFactoryScript.style_action_btn(rush_button, RUSH_ACCENT)
	rush_button.pressed.connect(rush_pressed)
	progress_container.add_child(rush_button)
	refs["rush_button"] = rush_button

	BuildingPanelFactoryScript.panel_sep(body, accent)
	var upgrade_button := Button.new()
	upgrade_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	upgrade_button.text = "⬆  Upgrade Building   (Coming Soon)"
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.disabled = true
	BuildingPanelFactoryScript.style_action_btn(upgrade_button, DISABLED_ACCENT)
	body.add_child(upgrade_button)
	refs["upgrade_button"] = upgrade_button

	return refs


static func _selector_button(text: String, pressed: Callable, width: float) -> Button:
	var button := Button.new()
	button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	button.text = text
	button.custom_minimum_size = Vector2(width, 0)
	button.pressed.connect(pressed)
	return button


static func _build_spread_result_popup(ui: CanvasLayer) -> Dictionary:
	var refs: Dictionary = {}
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	ui.add_child(overlay)
	refs["popup"] = overlay

	var panel := PanelContainer.new()
	panel.layout_direction = Control.LAYOUT_DIRECTION_LTR
	panel.add_theme_stylebox_override("panel", _spread_result_style())
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -220
	panel.offset_right = 220
	panel.offset_top = -110
	panel.offset_bottom = 110
	overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.layout_direction = Control.LAYOUT_DIRECTION_LTR
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title := Label.new()
	title.layout_direction = Control.LAYOUT_DIRECTION_LTR
	title.text = "✉  Mission Complete!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color(0.30, 0.90, 0.80))
	vbox.add_child(title)

	var result_label := Label.new()
	result_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 14)
	result_label.add_theme_color_override("font_color", Color(0.92, 0.90, 0.98))
	vbox.add_child(result_label)
	refs["label"] = result_label

	var ok_button := Button.new()
	ok_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	ok_button.text = "Praise be!"
	ok_button.pressed.connect(func(): overlay.visible = false)
	BuildingPanelFactoryScript.style_action_btn(ok_button, SPREAD_ACCENT)
	vbox.add_child(ok_button)
	return refs


static func _spread_result_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.14)
	style.border_color = Color(0.30, 0.80, 0.75)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	return style
