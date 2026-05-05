@tool
class_name WheelSpinnerDrawer
extends Node2D

const WheelOfFaithScript: GDScript = preload("res://scripts/systems/wheel_of_faith.gd")

const RADIUS := 155.0
const STEPS := 32


func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	var segment_count: int = WheelOfFaithScript.SEGMENTS.size()
	var seg_angle: float = TAU / float(segment_count)

	draw_circle(Vector2(5, 5), RADIUS + 14, Color(0, 0, 0, 0.35))
	draw_circle(Vector2.ZERO, RADIUS + 12, Color(0.92, 0.74, 0.12))
	draw_circle(Vector2.ZERO, RADIUS + 7, Color(0.55, 0.36, 0.04))
	draw_circle(Vector2.ZERO, RADIUS + 4, Color(0.80, 0.60, 0.08))

	for i in range(segment_count):
		var a_start: float = float(i) * seg_angle - PI * 0.5
		var a_end: float = a_start + seg_angle
		var seg: Dictionary = WheelOfFaithScript.SEGMENTS[i]
		var color: Color = seg.color

		var pts := PackedVector2Array()
		pts.append(Vector2.ZERO)
		for s in range(STEPS + 1):
			var a: float = a_start + (a_end - a_start) * float(s) / float(STEPS)
			pts.append(Vector2(cos(a), sin(a)) * RADIUS)
		draw_colored_polygon(pts, color)

		var arc_pts := PackedVector2Array()
		for s in range(STEPS + 1):
			var a: float = a_start + (a_end - a_start) * float(s) / float(STEPS)
			arc_pts.append(Vector2(cos(a), sin(a)) * (RADIUS - 2.0))
		draw_polyline(arc_pts, color.lightened(0.35), 4.0)

	for i in range(segment_count):
		var a: float = float(i) * seg_angle - PI * 0.5
		draw_line(Vector2.ZERO, Vector2(cos(a), sin(a)) * (RADIUS + 4), Color(0.85, 0.65, 0.08), 2.5)

	for i in range(segment_count):
		var mid_angle: float = float(i) * seg_angle - PI * 0.5 + seg_angle * 0.5
		draw_set_transform(Vector2.ZERO, mid_angle, Vector2.ONE)
		var txt: String = _display_label(WheelOfFaithScript.SEGMENTS[i])
		draw_string(font, Vector2(RADIUS * 0.38, 5), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0, 0, 0, 0.6))
		draw_string(font, Vector2(RADIUS * 0.38, 4), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.97, 0.85))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_circle(Vector2.ZERO, 26, Color(0.92, 0.74, 0.12))
	draw_circle(Vector2.ZERO, 20, Color(0.18, 0.10, 0.30))
	draw_circle(Vector2.ZERO, 12, Color(0.88, 0.70, 0.10))
	draw_circle(Vector2.ZERO, 6, Color(0.98, 0.92, 0.55))


func _display_label(segment: Dictionary) -> String:
	match segment.type:
		"bad":
			return "Dark Omen"
		"card":
			return "Aldric"
		_:
			return str(segment.label).replace("Blessing\n", "")
