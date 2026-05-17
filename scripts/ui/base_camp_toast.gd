extends RefCounted

var label: Label = null
var tree: SceneTree = null


func setup(toast_label: Label, scene_tree: SceneTree) -> void:
	label = toast_label
	tree = scene_tree


func show(msg: String, seconds: float = 5.0) -> void:
	if label == null:
		return

	label.text = msg

	if tree == null:
		return

	tree.create_timer(seconds).timeout.connect(func():
		if label != null and label.text == msg:
			label.text = ""
	)
