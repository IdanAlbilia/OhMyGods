extends RefCounted

var conversion_panel: PanelContainer = null
var training_panel: PanelContainer = null
var preacher_shelter_panel: PanelContainer = null
var garrison_panel: PanelContainer = null
var shelter_panel: PanelContainer = null
var extra_shelter_panel: PanelContainer = null
var temple_panel: Control = null


func setup(refs: Dictionary) -> void:
	conversion_panel = refs.get("conversion_panel", null)
	training_panel = refs.get("training_panel", null)
	preacher_shelter_panel = refs.get("preacher_shelter_panel", null)
	garrison_panel = refs.get("garrison_panel", null)
	shelter_panel = refs.get("shelter_panel", null)
	extra_shelter_panel = refs.get("extra_shelter_panel", null)
	temple_panel = refs.get("temple_panel", null)


func hide_action_panels(except_key: String = "") -> void:
	_set_visible("conversion", conversion_panel, except_key == "conversion")
	_set_visible("training", training_panel, except_key == "training")
	_set_visible("preacher_shelter", preacher_shelter_panel, except_key == "preacher_shelter")
	_set_visible("garrison", garrison_panel, except_key == "garrison")
	_set_visible("shelter", shelter_panel, except_key == "shelter")
	_set_visible("extra_shelter", extra_shelter_panel, except_key == "extra_shelter")
	_set_visible("temple", temple_panel, except_key == "temple")


func toggle_panel(panel_key: String) -> bool:
	var panel := _panel_for_key(panel_key)
	if panel == null:
		hide_action_panels()
		return false

	var should_show := not panel.visible
	hide_action_panels(panel_key)
	panel.visible = should_show
	return should_show


func _set_visible(_key: String, panel: Control, keep_visible: bool) -> void:
	if panel == null:
		return
	if not keep_visible:
		panel.visible = false


func _panel_for_key(panel_key: String) -> Control:
	match panel_key:
		"conversion":
			return conversion_panel
		"training":
			return training_panel
		"preacher_shelter":
			return preacher_shelter_panel
		"garrison":
			return garrison_panel
		"shelter":
			return shelter_panel
		"extra_shelter":
			return extra_shelter_panel
		"temple":
			return temple_panel
		_:
			return null
