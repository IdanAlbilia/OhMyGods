class_name WheelOfFaithPopup
extends ColorRect

signal spin_pressed
signal spin_finished(seg_index: int)

const WheelOfFaithScript: GDScript = preload("res://scripts/systems/wheel_of_faith.gd")

@onready var _spinner: Node2D = %Spinner
@onready var _spin_btn: Button = %SpinButton
@onready var _result_label: Label = %ResultLabel
@onready var _result_panel: PanelContainer = %ResultPanel
@onready var _close_button: Button = %CloseButton

var _spinning: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	mouse_filter = Control.MOUSE_FILTER_STOP
	get_viewport().size_changed.connect(_fit_to_viewport)
	_spin_btn.pressed.connect(func(): spin_pressed.emit())
	_close_button.pressed.connect(func(): visible = false)
	_fit_to_viewport()
	visible = false


func open(can_spin: bool) -> void:
	_fit_to_viewport()
	visible = true
	if _spin_btn != null:
		_spin_btn.disabled = _spinning or not can_spin


func start_spin(target_seg: int) -> void:
	if _spinning:
		return

	_spinning = true
	_spin_btn.disabled = true
	_result_panel.visible = false

	var seg_angle: float = TAU / WheelOfFaithScript.SEGMENTS.size()
	var landing_angle: float = -float(target_seg) * seg_angle - seg_angle * 0.5
	var total_rotation: float = TAU * 5.0 + landing_angle - fmod(_spinner.rotation, TAU)

	var tween := create_tween()
	tween.tween_property(_spinner, "rotation", _spinner.rotation + total_rotation, 3.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): _finish_spin(target_seg))


func show_result(text: String) -> void:
	_result_label.text = text
	_result_panel.visible = true


func _finish_spin(seg_index: int) -> void:
	_spinning = false
	spin_finished.emit(seg_index)


func _fit_to_viewport() -> void:
	if not is_inside_tree():
		return
	position = Vector2.ZERO
	size = get_viewport_rect().size
