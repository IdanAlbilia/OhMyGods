extends SceneTree

const PANEL_SCENE := preload("res://scenes/ui/temple_panel.tscn")


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var panel: Control = PANEL_SCENE.instantiate()
	viewport.add_child(panel)
	await process_frame

	if panel.visible:
		push_error("Temple panel should start hidden.")
		quit(1)
		return

	panel.toggle_panel()
	if not panel.visible:
		push_error("Temple panel did not toggle open.")
		quit(1)
		return

	var row: VBoxContainer = panel.add_prayer_session_row(2)
	if row == null or row.get_node_or_null("bar_bg/bar") == null:
		push_error("Temple panel did not create a valid prayer session row.")
		quit(1)
		return

	panel.set_praying_count(2)
	print("Temple panel test passed.")
	quit(0)
