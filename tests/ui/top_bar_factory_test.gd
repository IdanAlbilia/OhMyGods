extends SceneTree

const TopBarFactoryScript: GDScript = preload("res://scripts/ui/top_bar_factory.gd")

var _people_clicked := false


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var ui := CanvasLayer.new()
	viewport.add_child(ui)

	var refs: Dictionary = TopBarFactoryScript.build(
		ui,
		true,
		false,
		_on_people_input,
		func(_event: InputEvent): pass,
		func(_event: InputEvent): pass,
		func(_event: InputEvent): pass,
		func(_event: InputEvent): pass
	)
	await process_frame

	if refs["believers_label"] == null or refs["faith_label"] == null or refs["gold_label"] == null:
		push_error("Top bar should return resource labels.")
		quit(1)
		return

	if not refs["wheel_chip"].visible:
		push_error("Wheel chip should be visible when a spin is available.")
		quit(1)
		return

	if not refs["campaign_chip"].visible:
		push_error("Campaign chip should be visible when no mission is active.")
		quit(1)
		return

	if refs["return_mission_chip"].visible:
		push_error("Return mission chip should be hidden when no mission is active.")
		quit(1)
		return

	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	refs["believers_label"].get_parent().get_parent().emit_signal("gui_input", click)
	if not _people_clicked:
		push_error("People chip should forward gui_input to its callback.")
		quit(1)
		return

	print("Top bar factory test passed.")
	quit(0)


func _on_people_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_people_clicked = true
