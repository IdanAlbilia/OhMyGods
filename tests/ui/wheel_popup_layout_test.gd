extends SceneTree

const POPUP_SCENE := preload("res://scenes/ui/wheel_of_faith_popup.tscn")


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var popup: Control = POPUP_SCENE.instantiate()
	viewport.add_child(popup)
	await process_frame
	popup.open(true)

	await process_frame
	await process_frame

	var panel := popup.find_child("Panel", true, false) as Control
	if panel == null:
		push_error("Wheel popup panel was not found.")
		quit(1)
		return

	var viewport_center := Vector2(viewport.size) * 0.5
	var panel_center := panel.global_position + panel.size * 0.5
	if panel_center.distance_to(viewport_center) > 1.0:
		push_error("Wheel popup panel is not centered. Panel center: %s Viewport center: %s" % [panel_center, viewport_center])
		quit(1)
		return

	print("Wheel popup layout test passed.")
	quit(0)
