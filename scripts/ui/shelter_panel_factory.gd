class_name ShelterPanelFactory
extends RefCounted

const BuildingPanelFactoryScript: GDScript = preload("res://scripts/ui/building_panel_factory.gd")

const SHELTER_ACCENT := Color(0.85, 0.55, 0.18)
const COUNT_COLOR := Color(0.92, 0.75, 0.38)
const PRAYER_ACCENT := Color(0.55, 0.35, 0.82)
const RUSH_ACCENT := Color(0.85, 0.65, 0.10)
const DISABLED_ACCENT := Color(0.50, 0.48, 0.44)


static func build_humble(
	ui: CanvasLayer,
	go_pressed: Callable,
	minus_pressed: Callable,
	plus_pressed: Callable,
	confirm_pressed: Callable,
	cancel_pressed: Callable,
	rush_pressed: Callable
) -> Dictionary:
	var refs := _build_common_shell(ui, "Humble Shelter", "Believers")
	var body: VBoxContainer = refs["body"]

	var tutorial_arrow := Label.new()
	tutorial_arrow.layout_direction = Control.LAYOUT_DIRECTION_LTR
	tutorial_arrow.text = "↓  Tap Go Pray!"
	tutorial_arrow.add_theme_font_size_override("font_size", 14)
	tutorial_arrow.add_theme_color_override("font_color", Color(1.0, 0.18, 0.18))
	tutorial_arrow.visible = false
	body.add_child(tutorial_arrow)
	refs["tutorial_arrow"] = tutorial_arrow

	var go_button := _add_go_button(body, go_pressed)
	refs["go_button"] = go_button

	var selector_refs := _add_selector_row(body, minus_pressed, plus_pressed, confirm_pressed, cancel_pressed)
	refs.merge(selector_refs, true)

	var progress_container := VBoxContainer.new()
	progress_container.layout_direction = Control.LAYOUT_DIRECTION_LTR
	progress_container.add_theme_constant_override("separation", 6)
	progress_container.visible = false
	body.add_child(progress_container)
	refs["progress_container"] = progress_container

	var status_label := Label.new()
	status_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	status_label.text = "Praying: 1 believer — 30:00"
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	progress_container.add_child(status_label)
	refs["status_label"] = status_label

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.10, 0.08, 0.18)
	bar_bg.custom_minimum_size = Vector2(0, 8)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_container.add_child(bar_bg)

	var progress_bar := ColorRect.new()
	progress_bar.color = PRAYER_ACCENT
	progress_bar.anchor_top = 0.0
	progress_bar.anchor_bottom = 1.0
	progress_bar.anchor_left = 0.0
	progress_bar.anchor_right = 0.0
	bar_bg.add_child(progress_bar)
	refs["progress_bar"] = progress_bar

	var rush_button := Button.new()
	rush_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	rush_button.text = "⚡ -10m"
	rush_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rush_button.pressed.connect(rush_pressed)
	BuildingPanelFactoryScript.style_action_btn(rush_button, RUSH_ACCENT)
	progress_container.add_child(rush_button)
	refs["rush_button"] = rush_button

	_add_upgrade(body)
	return refs


static func build_extra(
	ui: CanvasLayer,
	go_pressed: Callable,
	minus_pressed: Callable,
	plus_pressed: Callable,
	confirm_pressed: Callable,
	cancel_pressed: Callable
) -> Dictionary:
	var refs := _build_common_shell(ui, "Believer Shelter", "Believers")
	var body: VBoxContainer = refs["body"]

	refs["go_button"] = _add_go_button(body, go_pressed)
	refs.merge(_add_selector_row(body, minus_pressed, plus_pressed, confirm_pressed, cancel_pressed), true)

	var progress_container := VBoxContainer.new()
	progress_container.layout_direction = Control.LAYOUT_DIRECTION_LTR
	progress_container.add_theme_constant_override("separation", 4)
	progress_container.visible = false
	body.add_child(progress_container)
	refs["progress_container"] = progress_container

	var progress_label := Label.new()
	progress_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	progress_label.text_direction = Control.TEXT_DIRECTION_LTR
	progress_label.text = "Praying..."
	progress_label.add_theme_font_size_override("font_size", 13)
	progress_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	progress_container.add_child(progress_label)
	refs["progress_label"] = progress_label

	_add_upgrade(body)
	return refs


static func _build_common_shell(ui: CanvasLayer, title: String, count_label: String) -> Dictionary:
	var refs: Dictionary = {}
	var panel: PanelContainer = BuildingPanelFactoryScript.make_panel(ui, SHELTER_ACCENT, title)
	refs["panel"] = panel

	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(panel)
	refs["body"] = body
	refs["count_label"] = BuildingPanelFactoryScript.count_row(body, count_label, COUNT_COLOR)
	BuildingPanelFactoryScript.panel_sep(body, SHELTER_ACCENT)
	return refs


static func _add_go_button(body: VBoxContainer, pressed: Callable) -> Button:
	var button := Button.new()
	button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	button.text = "🙏  Go Pray  (30 min)"
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(pressed)
	BuildingPanelFactoryScript.style_action_btn(button, PRAYER_ACCENT)
	body.add_child(button)
	return button


static func _add_selector_row(
	body: VBoxContainer,
	minus_pressed: Callable,
	plus_pressed: Callable,
	confirm_pressed: Callable,
	cancel_pressed: Callable
) -> Dictionary:
	var refs := {}
	var row := HBoxContainer.new()
	row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	row.add_theme_constant_override("separation", 4)
	row.visible = false
	body.add_child(row)
	refs["selector_row"] = row

	var minus_button := _selector_button("−", minus_pressed)
	row.add_child(minus_button)
	refs["minus_button"] = minus_button

	var selector_label := Label.new()
	selector_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	selector_label.text_direction = Control.TEXT_DIRECTION_LTR
	selector_label.text = "1 believer"
	selector_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selector_label.add_theme_font_size_override("font_size", 13)
	selector_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	row.add_child(selector_label)
	refs["selector_label"] = selector_label

	var plus_button := _selector_button("+", plus_pressed)
	row.add_child(plus_button)
	refs["plus_button"] = plus_button

	var confirm_button := Button.new()
	confirm_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	confirm_button.text = "Send to Pray"
	confirm_button.pressed.connect(confirm_pressed)
	BuildingPanelFactoryScript.style_action_btn(confirm_button, PRAYER_ACCENT)
	row.add_child(confirm_button)
	refs["confirm_button"] = confirm_button

	var cancel_button := Button.new()
	cancel_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(cancel_pressed)
	BuildingPanelFactoryScript.style_action_btn(cancel_button, DISABLED_ACCENT)
	row.add_child(cancel_button)
	refs["cancel_button"] = cancel_button

	return refs


static func _selector_button(text: String, pressed: Callable) -> Button:
	var button := Button.new()
	button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	button.text = text
	button.custom_minimum_size = Vector2(30, 0)
	button.pressed.connect(pressed)
	BuildingPanelFactoryScript.style_action_btn(button, PRAYER_ACCENT)
	return button


static func _add_upgrade(body: VBoxContainer) -> Button:
	BuildingPanelFactoryScript.panel_sep(body, SHELTER_ACCENT)
	var button := Button.new()
	button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	button.text = "⬆  Upgrade Building   (Coming Soon)"
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.disabled = true
	BuildingPanelFactoryScript.style_action_btn(button, DISABLED_ACCENT)
	body.add_child(button)
	return button
