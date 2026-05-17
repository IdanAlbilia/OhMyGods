class_name RoadNavigator
extends RefCounted


static func corner(from_pos: Vector2, to_pos: Vector2) -> Vector2:
	return Vector2(from_pos.x, to_pos.y)


static func walk_via_road(node, from_pos: Vector2, to_pos: Vector2, on_arrive: Callable) -> void:
	# Mirrors the road visuals so characters follow the same L-shaped route.
	if to_pos.y < from_pos.y - 20.0:
		var road_y := from_pos.y + 60.0
		var p1 := Vector2(from_pos.x, road_y)
		var p2 := Vector2(to_pos.x, road_y)
		node.walk_to(p1)
		node.reached_forced_target.connect(func():
			node.walk_to(p2)
			node.reached_forced_target.connect(func():
				node.walk_to(to_pos)
				node.reached_forced_target.connect(on_arrive, CONNECT_ONE_SHOT)
			, CONNECT_ONE_SHOT)
		, CONNECT_ONE_SHOT)
	else:
		var road_corner := corner(from_pos, to_pos)
		if road_corner.distance_to(to_pos) < 4.0 or road_corner.distance_to(from_pos) < 4.0:
			node.walk_to(to_pos)
			node.reached_forced_target.connect(on_arrive, CONNECT_ONE_SHOT)
		else:
			node.walk_to(road_corner)
			node.reached_forced_target.connect(func():
				node.walk_to(to_pos)
				node.reached_forced_target.connect(on_arrive, CONNECT_ONE_SHOT)
			, CONNECT_ONE_SHOT)
