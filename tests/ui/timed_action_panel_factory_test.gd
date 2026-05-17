extends SceneTree

const TimedActionPanelFactoryScript: GDScript = preload("res://scripts/ui/timed_action_panel_factory.gd")

var _primary_pressed := false
var _rush_pressed := false


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var ui := CanvasLayer.new()
	viewport.add_child(ui)

	var refs: Dictionary = TimedActionPanelFactoryScript.build(
		ui,
		Color(0.35, 0.55, 1.00),
		"Hall of the Devoted",
		"Ready to convert",
		"Convert Believer  (1 hr)",
		_on_primary_pressed,
		_on_rush_pressed
	)
	await process_frame

	var panel: PanelContainer = refs["panel"]
	var status_label: Label = refs["status_label"]
	var progress_bar: ColorRect = refs["progress_bar"]
	var primary_button: Button = refs["primary_button"]
	var rush_button: Button = refs["rush_button"]
	var upgrade_button: Button = refs["upgrade_button"]

	if panel == null or status_label == null or progress_bar == null:
		push_error("Timed action panel factory should return panel, label, and progress refs.")
		quit(1)
		return
	if primary_button == null or rush_button == null or upgrade_button == null:
		push_error("Timed action panel factory should return all button refs.")
		quit(1)
		return
	if panel.visible:
		push_error("Timed action panel should start hidden.")
		quit(1)
		return
	if panel.get_parent() != ui:
		push_error("Timed action panel should be added to the supplied UI layer.")
		quit(1)
		return
	if rush_button.visible:
		push_error("Rush button should start hidden.")
		quit(1)
		return
	if not upgrade_button.disabled:
		push_error("Upgrade button should start disabled.")
		quit(1)
		return

	status_label.text = "Working"
	progress_bar.anchor_right = 0.25
	if status_label.text != "Working" or not is_equal_approx(progress_bar.anchor_right, 0.25):
		push_error("Timed action panel refs should remain writable by the game screen.")
		quit(1)
		return

	primary_button.pressed.emit()
	rush_button.pressed.emit()
	if not _primary_pressed or not _rush_pressed:
		push_error("Timed action panel buttons should call the supplied callbacks.")
		quit(1)
		return

	print("Timed action panel factory test passed.")
	quit(0)


func _on_primary_pressed() -> void:
	_primary_pressed = true


func _on_rush_pressed() -> void:
	_rush_pressed = true
