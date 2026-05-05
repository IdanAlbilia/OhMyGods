class_name CameraController
extends RefCounted

const ZOOM_MIN := 0.40
const ZOOM_MAX := 2.50
const ZOOM_FACTOR := 1.12

var camera: Camera2D = null
var is_panning: bool = false
var pan_start_mouse: Vector2 = Vector2.ZERO
var pan_start_cam: Vector2 = Vector2.ZERO


func setup(target_camera: Camera2D) -> void:
	camera = target_camera


func zoom(screen_pivot: Vector2, viewport_size: Vector2, direction: int) -> void:
	if camera == null:
		return

	var old_zoom := camera.zoom.x
	var new_zoom: float = clampf(
		old_zoom * (ZOOM_FACTOR if direction > 0 else 1.0 / ZOOM_FACTOR),
		ZOOM_MIN,
		ZOOM_MAX
	)

	if is_equal_approx(new_zoom, old_zoom):
		return

	var vp_center := viewport_size * 0.5
	var world_pivot := camera.position + (screen_pivot - vp_center) / old_zoom

	camera.zoom = Vector2(new_zoom, new_zoom)
	camera.position = world_pivot - (screen_pivot - vp_center) / new_zoom


func start_pan(mouse_position: Vector2) -> void:
	if camera == null:
		return

	is_panning = true
	pan_start_mouse = mouse_position
	pan_start_cam = camera.position


func update_pan(mouse_position: Vector2) -> void:
	if camera == null or not is_panning:
		return

	camera.position = pan_start_cam - (mouse_position - pan_start_mouse) / camera.zoom.x


func stop_pan() -> void:
	is_panning = false
