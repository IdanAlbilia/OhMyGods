extends SceneTree

const PANEL_SCENE := preload("res://scenes/ui/hero_deck_panel.tscn")


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var panel: Control = PANEL_SCENE.instantiate()
	viewport.add_child(panel)
	await process_frame

	if panel.visible:
		push_error("Hero deck panel should start hidden.")
		quit(1)
		return

	panel.toggle_panel()
	if not panel.visible:
		push_error("Hero deck panel did not toggle open.")
		quit(1)
		return

	panel.hide_panel()
	if panel.visible:
		push_error("Hero deck panel did not hide.")
		quit(1)
		return

	print("Hero deck panel test passed.")
	quit(0)
