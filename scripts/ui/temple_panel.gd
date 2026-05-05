class_name TemplePanel
extends PanelContainer

@onready var _praying_label: Label = %PrayingValue
@onready var _session_rows: VBoxContainer = %SessionRows


func _ready() -> void:
	visible = false


func toggle_panel() -> void:
	visible = not visible


func set_praying_count(count: int) -> void:
	_praying_label.text = "%d / 5" % count
	_session_rows.visible = _session_rows.get_child_count() > 0


func add_prayer_session_row(count: int) -> VBoxContainer:
	var row := _make_prayer_session_row(count)
	_session_rows.add_child(row)
	_session_rows.visible = true
	return row


func refresh_session_rows() -> void:
	_session_rows.visible = _session_rows.get_child_count() > 0


func _make_prayer_session_row(count: int) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.layout_direction = Control.LAYOUT_DIRECTION_LTR
	vb.add_theme_constant_override("separation", 3)
	vb.name = "session_row"
	var s_plural := "s" if count > 1 else ""
	var lbl := Label.new()
	lbl.layout_direction = Control.LAYOUT_DIRECTION_LTR
	lbl.text_direction = Control.TEXT_DIRECTION_LTR
	lbl.text = "%d believer%s praying  (+%d faith/min)" % [count, s_plural, count]
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.72, 1.00))
	vb.add_child(lbl)

	var bar_bg := ColorRect.new()
	bar_bg.name = "bar_bg"
	bar_bg.color = Color(0.10, 0.08, 0.18)
	bar_bg.custom_minimum_size = Vector2(0, 8)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(bar_bg)

	var bar := ColorRect.new()
	bar.name = "bar"
	bar.color = Color(0.72, 0.55, 1.00)
	bar.anchor_top = 0.0
	bar.anchor_bottom = 1.0
	bar.anchor_left = 0.0
	bar.anchor_right = 0.0
	bar_bg.add_child(bar)
	return vb

