extends SceneTree

const RoadNavigatorScript: GDScript = preload("res://scripts/systems/road_navigator.gd")


class Walker extends Node:
	signal reached_forced_target

	var targets: Array = []

	func walk_to(pos: Vector2) -> void:
		targets.append(pos)


var _arrived := false


func _init() -> void:
	if RoadNavigatorScript.corner(Vector2(10, 20), Vector2(80, 90)) != Vector2(10, 90):
		push_error("Road corner should keep the origin x and destination y.")
		quit(1)
		return

	_assert_vertical_first_route()
	_assert_above_destination_route()

	print("Road navigator test passed.")
	quit(0)


func _assert_vertical_first_route() -> void:
	_arrived = false
	var walker := Walker.new()
	root.add_child(walker)

	RoadNavigatorScript.walk_via_road(
		walker,
		Vector2(0, 0),
		Vector2(20, 30),
		func(): _arrived = true
	)
	if walker.targets != [Vector2(0, 30)]:
		push_error("Vertical-first route should start at the L-corner.")
		quit(1)
		return

	walker.reached_forced_target.emit()
	if walker.targets != [Vector2(0, 30), Vector2(20, 30)]:
		push_error("Vertical-first route should continue to the destination.")
		quit(1)
		return

	walker.reached_forced_target.emit()
	if not _arrived:
		push_error("Vertical-first route should call on_arrive.")
		quit(1)


func _assert_above_destination_route() -> void:
	_arrived = false
	var walker := Walker.new()
	root.add_child(walker)

	RoadNavigatorScript.walk_via_road(
		walker,
		Vector2(0, 100),
		Vector2(50, 20),
		func(): _arrived = true
	)
	if walker.targets != [Vector2(0, 160)]:
		push_error("Above-destination route should exit south first.")
		quit(1)
		return

	walker.reached_forced_target.emit()
	if walker.targets != [Vector2(0, 160), Vector2(50, 160)]:
		push_error("Above-destination route should move horizontally on the road.")
		quit(1)
		return

	walker.reached_forced_target.emit()
	if walker.targets != [Vector2(0, 160), Vector2(50, 160), Vector2(50, 20)]:
		push_error("Above-destination route should finish at the destination.")
		quit(1)
		return

	walker.reached_forced_target.emit()
	if not _arrived:
		push_error("Above-destination route should call on_arrive.")
		quit(1)
