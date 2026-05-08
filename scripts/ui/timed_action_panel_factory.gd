class_name TimedActionPanelFactory
extends RefCounted

const BuildingPanelFactoryScript: GDScript = preload("res://scripts/ui/building_panel_factory.gd")


static func build(
	ui: CanvasLayer,
	accent: Color,
	title: String,
	initial_status: String,
	primary_text: String,
	primary_pressed: Callable,
	rush_pressed: Callable
) -> Dictionary:
	var refs := {}
	var panel: PanelContainer = BuildingPanelFactoryScript.make_panel(ui, accent, title)
	refs["panel"] = panel

	var body: VBoxContainer = BuildingPanelFactoryScript.panel_body(panel)

	var status_label := Label.new()
	status_label.layout_direction = Control.LAYOUT_DIRECTION_LTR
	status_label.text = initial_status
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.82))
	body.add_child(status_label)
	refs["status_label"] = status_label

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.10, 0.08, 0.18)
	bar_bg.custom_minimum_size = Vector2(0, 8)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(bar_bg)

	var progress_bar := ColorRect.new()
	progress_bar.color = accent
	progress_bar.anchor_top = 0.0
	progress_bar.anchor_bottom = 1.0
	progress_bar.anchor_left = 0.0
	progress_bar.anchor_right = 0.0
	bar_bg.add_child(progress_bar)
	refs["progress_bar"] = progress_bar

	var btn_row := HBoxContainer.new()
	btn_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	btn_row.add_theme_constant_override("separation", 8)
	body.add_child(btn_row)

	var primary_button := Button.new()
	primary_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	primary_button.text = primary_text
	primary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary_button.pressed.connect(primary_pressed)
	BuildingPanelFactoryScript.style_action_btn(primary_button, accent)
	btn_row.add_child(primary_button)
	refs["primary_button"] = primary_button

	var rush_button := Button.new()
	rush_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	rush_button.text = "⚡ -10m"
	rush_button.custom_minimum_size = Vector2(70, 0)
	rush_button.visible = false
	rush_button.pressed.connect(rush_pressed)
	BuildingPanelFactoryScript.style_action_btn(rush_button, Color(0.85, 0.65, 0.10))
	btn_row.add_child(rush_button)
	refs["rush_button"] = rush_button

	BuildingPanelFactoryScript.panel_sep(body, accent)

	var upgrade_button := Button.new()
	upgrade_button.layout_direction = Control.LAYOUT_DIRECTION_LTR
	upgrade_button.text = "⬆  Upgrade Building   (Coming Soon)"
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.disabled = true
	BuildingPanelFactoryScript.style_action_btn(upgrade_button, Color(0.50, 0.48, 0.44))
	body.add_child(upgrade_button)
	refs["upgrade_button"] = upgrade_button

	return refs
