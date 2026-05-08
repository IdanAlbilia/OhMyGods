extends SceneTree

const PeoplePanelFactoryScript: GDScript = preload("res://scripts/ui/people_panel_factory.gd")


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var ui := CanvasLayer.new()
	viewport.add_child(ui)

	var refs: Dictionary = PeoplePanelFactoryScript.build(ui)
	await process_frame

	var panel: PanelContainer = refs["panel"]
	var detail_label: Label = refs["detail_label"]
	if panel == null or detail_label == null:
		push_error("People panel factory should return the panel and detail label.")
		quit(1)
		return
	if panel.visible:
		push_error("People panel should start hidden.")
		quit(1)
		return
	if panel.get_parent() != ui:
		push_error("People panel should be added to the supplied UI layer.")
		quit(1)
		return

	detail_label.text = "Believers: 5"
	if detail_label.text != "Believers: 5":
		push_error("People detail label should be writable by the game screen.")
		quit(1)
		return

	print("People panel factory test passed.")
	quit(0)
