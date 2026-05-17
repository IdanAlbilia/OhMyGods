extends SceneTree

const ShelterPanelFactoryScript: GDScript = preload("res://scripts/ui/shelter_panel_factory.gd")

var _go_pressed := false
var _minus_pressed := false
var _plus_pressed := false
var _confirm_pressed := false
var _cancel_pressed := false
var _rush_pressed := false


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var ui := CanvasLayer.new()
	viewport.add_child(ui)

	var humble_refs: Dictionary = ShelterPanelFactoryScript.build_humble(
		ui,
		_on_go_pressed,
		_on_minus_pressed,
		_on_plus_pressed,
		_on_confirm_pressed,
		_on_cancel_pressed,
		_on_rush_pressed
	)
	var extra_refs: Dictionary = ShelterPanelFactoryScript.build_extra(
		ui,
		_on_go_pressed,
		_on_minus_pressed,
		_on_plus_pressed,
		_on_confirm_pressed,
		_on_cancel_pressed
	)
	await process_frame

	if not _assert_common_refs(humble_refs, "Humble"):
		return
	if not _assert_common_refs(extra_refs, "Extra"):
		return

	if humble_refs["tutorial_arrow"] == null or humble_refs["status_label"] == null:
		push_error("Humble shelter panel should return tutorial and status refs.")
		quit(1)
		return
	if humble_refs["progress_bar"] == null or humble_refs["rush_button"] == null:
		push_error("Humble shelter panel should return progress and rush refs.")
		quit(1)
		return
	if extra_refs["progress_container"] == null or extra_refs["progress_label"] == null:
		push_error("Extra shelter panel should return progress refs.")
		quit(1)
		return

	humble_refs["go_button"].pressed.emit()
	humble_refs["minus_button"].pressed.emit()
	humble_refs["plus_button"].pressed.emit()
	humble_refs["confirm_button"].pressed.emit()
	humble_refs["cancel_button"].pressed.emit()
	humble_refs["rush_button"].pressed.emit()
	if not (_go_pressed and _minus_pressed and _plus_pressed and _confirm_pressed and _cancel_pressed and _rush_pressed):
		push_error("Humble shelter controls should call supplied callbacks.")
		quit(1)
		return

	print("Shelter panel factory test passed.")
	quit(0)


func _assert_common_refs(refs: Dictionary, label: String) -> bool:
	var panel: PanelContainer = refs["panel"]
	var count_label: Label = refs["count_label"]
	var go_button: Button = refs["go_button"]
	var selector_row: HBoxContainer = refs["selector_row"]
	var selector_label: Label = refs["selector_label"]
	var upgrade_button: Button = _find_upgrade_button(panel)

	if panel == null or count_label == null or go_button == null or selector_row == null or selector_label == null:
		push_error("%s shelter panel should return common refs." % label)
		quit(1)
		return false
	if panel.visible:
		push_error("%s shelter panel should start hidden." % label)
		quit(1)
		return false
	if panel.get_parent() == null:
		push_error("%s shelter panel should be added to the UI tree." % label)
		quit(1)
		return false
	if selector_row.visible:
		push_error("%s shelter selector row should start hidden." % label)
		quit(1)
		return false
	if upgrade_button == null or not upgrade_button.disabled:
		push_error("%s shelter upgrade button should exist and be disabled." % label)
		quit(1)
		return false

	count_label.text = "3 / 5"
	selector_label.text = "2 believers"
	if count_label.text != "3 / 5" or selector_label.text != "2 believers":
		push_error("%s shelter refs should remain writable by the game screen." % label)
		quit(1)
		return false
	return true


func _find_upgrade_button(node: Node) -> Button:
	if node is Button and node.text.contains("Upgrade"):
		return node
	for child in node.get_children():
		var found := _find_upgrade_button(child)
		if found != null:
			return found
	return null


func _on_go_pressed() -> void:
	_go_pressed = true


func _on_minus_pressed() -> void:
	_minus_pressed = true


func _on_plus_pressed() -> void:
	_plus_pressed = true


func _on_confirm_pressed() -> void:
	_confirm_pressed = true


func _on_cancel_pressed() -> void:
	_cancel_pressed = true


func _on_rush_pressed() -> void:
	_rush_pressed = true
