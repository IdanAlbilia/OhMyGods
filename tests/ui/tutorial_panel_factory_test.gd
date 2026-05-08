extends SceneTree

const TutorialPanelFactoryScript: GDScript = preload("res://scripts/ui/tutorial/tutorial_panel_factory.gd")

var _ok_pressed := false


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var ui := CanvasLayer.new()
	viewport.add_child(ui)

	var refs: Dictionary = TutorialPanelFactoryScript.build(ui, "High Priest", 0, _on_ok_pressed)
	await process_frame

	var overlay: ColorRect = refs["overlay"]
	var popup: PanelContainer = refs["popup"]
	var popup_text: Label = refs["popup_text"]
	var shelter_arrow: PanelContainer = refs["shelter_arrow"]
	var shelter_arrow_label: Label = refs["shelter_arrow_label"]
	var rush_arrow: Label = refs["rush_arrow"]
	var wheel_arrow: PanelContainer = refs["wheel_arrow"]
	var toast_label: Label = refs["toast_label"]

	if overlay == null or popup == null or popup_text == null or shelter_arrow == null:
		push_error("Tutorial panel factory should return core tutorial refs.")
		quit(1)
		return
	if shelter_arrow_label == null or rush_arrow == null or wheel_arrow == null or toast_label == null:
		push_error("Tutorial panel factory should return hint and toast refs.")
		quit(1)
		return
	if overlay.visible or popup.visible or shelter_arrow.visible or rush_arrow.visible or wheel_arrow.visible:
		push_error("Tutorial popup and arrows should start hidden.")
		quit(1)
		return
	if overlay.get_parent() != ui or popup.get_parent() != ui or toast_label.get_parent() != ui:
		push_error("Tutorial nodes should be added to the supplied UI layer.")
		quit(1)
		return

	popup_text.text = "Welcome"
	shelter_arrow_label.text = "Tap"
	toast_label.text = "Not enough gold"
	if popup_text.text != "Welcome" or shelter_arrow_label.text != "Tap" or toast_label.text != "Not enough gold":
		push_error("Tutorial refs should remain writable by the game screen.")
		quit(1)
		return

	var button := _find_button(popup)
	if button == null:
		push_error("Tutorial popup should include an OK button.")
		quit(1)
		return
	button.pressed.emit()
	if not _ok_pressed:
		push_error("Tutorial OK button should call the supplied callback.")
		quit(1)
		return

	print("Tutorial panel factory test passed.")
	quit(0)


func _find_button(node: Node) -> Button:
	if node is Button:
		return node
	for child in node.get_children():
		var found := _find_button(child)
		if found != null:
			return found
	return null


func _on_ok_pressed() -> void:
	_ok_pressed = true
