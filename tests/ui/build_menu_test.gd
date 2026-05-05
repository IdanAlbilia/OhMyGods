extends SceneTree

const MENU_SCENE := preload("res://scenes/ui/build_menu.tscn")

var _requested_type := ""
var _requested_cost := 0


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var menu: Control = MENU_SCENE.instantiate()
	viewport.add_child(menu)
	await process_frame

	if menu.visible:
		push_error("Build menu should start hidden.")
		quit(1)
		return

	menu.toggle_menu()
	if not menu.visible:
		push_error("Build menu did not toggle open.")
		quit(1)
		return
	await process_frame

	var rect := menu.get_global_rect()
	if rect.position.x < 850.0 or rect.end.x > viewport.size.x:
		push_error("Build menu should be aligned to the right side of the screen, got %s." % rect)
		quit(1)
		return
	if _icon_count(menu) < 10:
		push_error("Build menu should show building thumbnails.")
		quit(1)
		return

	if menu.is_generals_quarters_unlocked():
		push_error("General's Quarters should start locked.")
		quit(1)
		return

	menu.set_generals_quarters_unlocked(true)
	if not menu.is_generals_quarters_unlocked():
		push_error("General's Quarters did not unlock.")
		quit(1)
		return

	menu.build_requested.connect(func(type: String, cost: int):
		_requested_type = type
		_requested_cost = cost
	)

	var first_button := _first_button(menu)
	if first_button == null:
		push_error("Build menu button was not found.")
		quit(1)
		return

	first_button.pressed.emit()
	if _requested_type != "temple" or _requested_cost != 30:
		push_error("Expected temple build request, got %s/%d." % [_requested_type, _requested_cost])
		quit(1)
		return

	print("Build menu test passed.")
	quit(0)


func _first_button(node: Node) -> Button:
	if node is Button and node.text == "Build":
		return node
	for child in node.get_children():
		var found := _first_button(child)
		if found != null:
			return found
	return null


func _icon_count(node: Node) -> int:
	var count := 0
	if node is TextureRect and node.name == "Icon":
		count += 1
	for child in node.get_children():
		count += _icon_count(child)
	return count
