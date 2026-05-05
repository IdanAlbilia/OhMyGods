class_name HeroDeckPanel
extends PanelContainer

@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	visible = false
	_close_button.pressed.connect(hide_panel)


func toggle_panel() -> void:
	visible = not visible


func hide_panel() -> void:
	visible = false
