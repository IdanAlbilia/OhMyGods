extends SceneTree

const BaseCampHudFactoryScript: GDScript = preload("res://scripts/ui/base_camp_hud_factory.gd")

var _build_pressed := false


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var ui := CanvasLayer.new()
	viewport.add_child(ui)

	var build_button: Button = BaseCampHudFactoryScript.build_button(ui, _on_build_pressed)
	var popup_refs: Dictionary = BaseCampHudFactoryScript.build_info_popup(ui)
	await process_frame

	var popup: PanelContainer = popup_refs["panel"]
	var label: Label = popup_refs["label"]
	if build_button == null or popup == null or label == null:
		push_error("HUD factory should return build button and popup refs.")
		quit(1)
		return
	if build_button.get_parent() != ui or popup.get_parent() != ui:
		push_error("HUD nodes should be added to the supplied UI layer.")
		quit(1)
		return
	if build_button.text != "Build":
		push_error("Build button should use the expected label.")
		quit(1)
		return
	if popup.visible:
		push_error("Info popup should start hidden.")
		quit(1)
		return

	label.text = "Temple"
	popup.position = Vector2(12, 34)
	if label.text != "Temple" or popup.position != Vector2(12, 34):
		push_error("Info popup refs should remain writable by the game screen.")
		quit(1)
		return

	build_button.pressed.emit()
	if not _build_pressed:
		push_error("Build button should call the supplied callback.")
		quit(1)
		return

	print("Base camp HUD factory test passed.")
	quit(0)


func _on_build_pressed() -> void:
	_build_pressed = true
