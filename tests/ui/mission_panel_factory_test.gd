extends SceneTree

const MissionPanelFactoryScript: GDScript = preload("res://scripts/ui/mission_panel_factory.gd")

var _go_pressed := false
var _minus_pressed := false
var _plus_pressed := false
var _confirm_pressed := false
var _rush_pressed := false


func _init() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	root.add_child(viewport)

	var ui := CanvasLayer.new()
	viewport.add_child(ui)

	var spread_refs: Dictionary = MissionPanelFactoryScript.build_spread_panel(
		ui,
		_on_go_pressed,
		_on_minus_pressed,
		_on_plus_pressed,
		_on_confirm_pressed,
		_on_rush_pressed
	)
	var crusade_refs: Dictionary = MissionPanelFactoryScript.build_crusade_panel(
		ui,
		_on_go_pressed,
		_on_minus_pressed,
		_on_plus_pressed,
		_on_confirm_pressed,
		_on_rush_pressed
	)
	await process_frame

	if not _assert_common_refs(spread_refs, "Spread"):
		return
	if not _assert_common_refs(crusade_refs, "Crusade"):
		return

	if spread_refs["result_popup"] == null or spread_refs["result_label"] == null:
		push_error("Spread panel should return result popup refs.")
		quit(1)
		return
	if crusade_refs["marcus_button"] == null:
		push_error("Crusade panel should return Marcus toggle ref.")
		quit(1)
		return

	spread_refs["go_button"].pressed.emit()
	spread_refs["minus_button"].pressed.emit()
	spread_refs["plus_button"].pressed.emit()
	spread_refs["confirm_button"].pressed.emit()
	spread_refs["rush_button"].pressed.emit()
	if not (_go_pressed and _minus_pressed and _plus_pressed and _confirm_pressed and _rush_pressed):
		push_error("Mission panel controls should call supplied callbacks.")
		quit(1)
		return

	print("Mission panel factory test passed.")
	quit(0)


func _assert_common_refs(refs: Dictionary, label: String) -> bool:
	var panel: PanelContainer = refs["panel"]
	var count_label: Label = refs["count_label"]
	var go_button: Button = refs["go_button"]
	var selector_row: HBoxContainer = refs["selector_row"]
	var selector_label: Label = refs["selector_label"]
	var progress_container: VBoxContainer = refs["progress_container"]
	var progress_label: Label = refs["progress_label"]
	var progress_bar: ColorRect = refs["progress_bar"]
	var rush_button: Button = refs["rush_button"]

	if panel == null or count_label == null or go_button == null or selector_row == null:
		push_error("%s panel should return core refs." % label)
		quit(1)
		return false
	if selector_label == null or progress_container == null or progress_label == null:
		push_error("%s panel should return selector and progress refs." % label)
		quit(1)
		return false
	if progress_bar == null or rush_button == null:
		push_error("%s panel should return progress bar and rush refs." % label)
		quit(1)
		return false
	if panel.visible or selector_row.visible or progress_container.visible:
		push_error("%s panel hidden regions should start hidden." % label)
		quit(1)
		return false

	count_label.text = "2 / 5"
	selector_label.text = "2 sent"
	progress_label.text = "Working"
	progress_bar.anchor_right = 0.5
	if count_label.text != "2 / 5" or selector_label.text != "2 sent":
		push_error("%s labels should remain writable by game screen." % label)
		quit(1)
		return false
	if progress_label.text != "Working" or not is_equal_approx(progress_bar.anchor_right, 0.5):
		push_error("%s progress refs should remain writable by game screen." % label)
		quit(1)
		return false
	return true


func _on_go_pressed() -> void:
	_go_pressed = true


func _on_minus_pressed() -> void:
	_minus_pressed = true


func _on_plus_pressed() -> void:
	_plus_pressed = true


func _on_confirm_pressed() -> void:
	_confirm_pressed = true


func _on_rush_pressed() -> void:
	_rush_pressed = true
