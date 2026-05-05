@tool
class_name WheelPointerDrawer
extends Node2D


func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-13, -5), Vector2(13, -5), Vector2(2, 30)
	]), Color(0, 0, 0, 0.35))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -8), Vector2(12, -8), Vector2(0, 28)
	]), Color(0.95, 0.18, 0.12))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-5, -7), Vector2(2, -7), Vector2(-3, 10)
	]), Color(1.0, 0.55, 0.50, 0.55))
	draw_polyline(PackedVector2Array([
		Vector2(-12, -8), Vector2(12, -8), Vector2(0, 28), Vector2(-12, -8)
	]), Color(0.55, 0.05, 0.02), 1.5)
