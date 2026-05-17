extends SceneTree

const ConstructionPanelFactoryScript: GDScript = preload("res://scripts/ui/construction_panel_factory.gd")

var _rush_pressed := false


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var ui := CanvasLayer.new()
	viewport.add_child(ui)

	var refs: Dictionary = ConstructionPanelFactoryScript.build(ui, _on_rush_pressed)
	await process_frame

	var panel: PanelContainer = refs["panel"]
	var label: Label = refs["label"]
	var bar: ColorRect = refs["bar"]
	var rush_button: Button = refs["rush_button"]

	if panel == null or label == null or bar == null or rush_button == null:
		push_error("Construction panel factory should return all writable refs.")
		quit(1)
		return
	if panel.visible:
		push_error("Construction panel should start hidden.")
		quit(1)
		return
	if panel.get_parent() != ui:
		push_error("Construction panel should be added to the supplied UI layer.")
		quit(1)
		return

	label.text = "Temple - 1:00"
	bar.anchor_right = 0.5
	if label.text != "Temple - 1:00" or not is_equal_approx(bar.anchor_right, 0.5):
		push_error("Construction panel refs should remain writable by the game screen.")
		quit(1)
		return

	rush_button.pressed.emit()
	if not _rush_pressed:
		push_error("Construction panel rush button should call the supplied callback.")
		quit(1)
		return

	print("Construction panel factory test passed.")
	quit(0)


func _on_rush_pressed() -> void:
	_rush_pressed = true
