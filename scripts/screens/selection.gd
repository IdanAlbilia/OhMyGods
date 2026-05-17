extends Control

var selected_god := -1
var selected_leader := -1
var god_cards := []
var leader_cards := []
var leader_sprites: Array = []
var begin_button: Button

const GODS = [
	{
		"name": "The Sun God",
		"icon": "☀",
		"desc": "God of light and warmth.\nRuler of the sky and all who bask beneath it."
	},
	{
		"name": "The Forest God",
		"icon": "🌿",
		"desc": "God of nature and growth.\nAncient spirit of the deep woods and wild places."
	},
	{
		"name": "The Sea God",
		"icon": "🌊",
		"desc": "God of storms and the unknown.\nMaster of tides, fate, and distant horizons."
	},
]

const LEADERS = [
	{
		"name": "High Priest",
		"desc": "+25% faith generation\nPreachers convert faster\nOccasional free miracle"
	},
	{
		"name": "Prophet of Wealth",
		"desc": "+25% gold generation\nBuildings cost less\nChance of rich pilgrim events"
	},
	{
		"name": "Holy General",
		"desc": "Stronger soldiers\nRaids more profitable\nCounter-raid immunity window"
	},
]

const COLOR_DEFAULT  = Color(0.18, 0.15, 0.25)
const COLOR_SELECTED = Color(0.75, 0.60, 0.10)
const COLOR_BG       = Color(0.08, 0.06, 0.12)
const COLOR_TITLE    = Color(0.95, 0.85, 0.40)


func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = COLOR_BG
	add_child(bg)

	# Single-screen layout — no scroll, everything fits in 648px
	var margin := MarginContainer.new()
	margin.layout_direction = Control.LAYOUT_DIRECTION_LTR
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top",    4)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.add_theme_constant_override("margin_left",   35)
	margin.add_theme_constant_override("margin_right",  35)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.layout_direction = Control.LAYOUT_DIRECTION_LTR
	vbox.add_theme_constant_override("separation", 1)
	margin.add_child(vbox)

	# ── Title ──────────────────────────────────────────────
	var title := Label.new()
	title.text = "✨  Oh my GOD!  ✨"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", COLOR_TITLE)
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Build your faith. Rule your people."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color(0.62, 0.60, 0.65))
	vbox.add_child(subtitle)

	_add_separator(vbox)

	# ── God Selection ──────────────────────────────────────
	var god_header := Label.new()
	god_header.text = "Choose Your God"
	god_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	god_header.add_theme_font_size_override("font_size", 19)
	god_header.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(god_header)

	var god_row := HBoxContainer.new()
	god_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	god_row.alignment = BoxContainer.ALIGNMENT_CENTER
	god_row.add_theme_constant_override("separation", 18)
	vbox.add_child(god_row)

	for i in range(GODS.size()):
		god_row.add_child(_make_god_card(GODS[i], i))

	_add_separator(vbox)

	# ── Leader Selection ───────────────────────────────────
	var leader_header := Label.new()
	leader_header.text = "Choose Your Religious Leader"
	leader_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	leader_header.add_theme_font_size_override("font_size", 19)
	leader_header.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(leader_header)

	var leader_row := HBoxContainer.new()
	leader_row.layout_direction = Control.LAYOUT_DIRECTION_LTR
	leader_row.alignment = BoxContainer.ALIGNMENT_CENTER
	leader_row.add_theme_constant_override("separation", 18)
	vbox.add_child(leader_row)

	for i in range(LEADERS.size()):
		leader_row.add_child(_make_leader_card(LEADERS[i], i))

	_add_separator(vbox)

	# ── Begin Button ───────────────────────────────────────
	begin_button = Button.new()
	begin_button.text = "Begin Your Reign"
	begin_button.custom_minimum_size = Vector2(240, 44)
	begin_button.add_theme_font_size_override("font_size", 19)
	begin_button.disabled = true
	begin_button.pressed.connect(_on_begin_pressed)

	var center := CenterContainer.new()
	center.add_child(begin_button)
	vbox.add_child(center)


# ── God card (unchanged layout, slightly larger) ──────────────────────────────
func _make_god_card(data: Dictionary, index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 122)

	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left    = 10
	style.corner_radius_top_right   = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left   = 2
	style.border_width_right  = 2
	style.border_width_top    = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.35, 0.28, 0.50)
	panel.add_theme_stylebox_override("panel", style)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	panel.add_child(inner)

	# Icon
	var icon_lbl := Label.new()
	icon_lbl.text = data["icon"]
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 30)
	inner.add_child(icon_lbl)

	# Name
	var name_lbl := Label.new()
	name_lbl.text = data["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", COLOR_TITLE)
	inner.add_child(name_lbl)

	# Description
	var desc_lbl := Label.new()
	desc_lbl.text = data["desc"]
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.80, 0.80, 0.80))
	inner.add_child(desc_lbl)

	# Spacer
	var sp := Control.new()
	sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(sp)

	# Select button
	var btn := Button.new()
	btn.text = "Select"
	btn.pressed.connect(_on_card_selected.bind(index, "god", panel, style, btn))
	inner.add_child(btn)

	god_cards.append({"panel": panel, "style": style, "btn": btn})
	return panel


# ── Leader card (portrait + info layout) ──────────────────────────────────────
func _make_leader_card(data: Dictionary, index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 252)

	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left    = 10
	style.corner_radius_top_right   = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left   = 2
	style.border_width_right  = 2
	style.border_width_top    = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.35, 0.28, 0.50)
	panel.add_theme_stylebox_override("panel", style)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	panel.add_child(inner)

	# Portrait — real PNG image with idle + select animation
	var leader_images := [
		"res://assets/characters/leaders/High Priest.png",
		"res://assets/characters/leaders/Prophet of Wealth.png",
		"res://assets/characters/leaders/Holy General.png"
	]
	var tex := TextureRect.new()
	tex.texture = load(leader_images[index])
	tex.custom_minimum_size = Vector2(200, 162)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.pivot_offset = Vector2(100, 180)
	inner.add_child(tex)
	leader_sprites.append(tex)

	# Name
	var name_lbl := Label.new()
	name_lbl.text = data["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", COLOR_TITLE)
	inner.add_child(name_lbl)

	# Description
	var desc_lbl := Label.new()
	desc_lbl.text = data["desc"]
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	inner.add_child(desc_lbl)

	# Spacer
	var sp := Control.new()
	sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(sp)

	# Select button
	var btn := Button.new()
	btn.text = "Select"
	btn.pressed.connect(_on_card_selected.bind(index, "leader", panel, style, btn))
	inner.add_child(btn)

	leader_cards.append({"panel": panel, "style": style, "btn": btn})
	return panel


func _on_card_selected(index: int, type: String, panel: PanelContainer, style: StyleBoxFlat, btn: Button):
	var list = god_cards if type == "god" else leader_cards

	# Reset all cards in this group
	for item in list:
		item["style"].bg_color = COLOR_DEFAULT
		item["style"].border_color = Color(0.35, 0.28, 0.50)
		item["btn"].text = "Select"

	# Highlight selected
	style.bg_color = COLOR_SELECTED
	style.border_color = Color(1.0, 0.85, 0.2)
	btn.text = "✓ Chosen"

	if type == "god":
		selected_god = index
	else:
		selected_leader = index
		for i in range(leader_sprites.size()):
			var spr: TextureRect = leader_sprites[i]
			if i == index:
				var tw := create_tween()
				tw.tween_property(spr, "scale", Vector2(1.12, 1.12), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
				tw.parallel().tween_property(spr, "modulate", Color(1.25, 1.20, 0.95, 1.0), 0.3).set_ease(Tween.EASE_OUT)
			else:
				var tw := create_tween()
				tw.tween_property(spr, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_IN)
				tw.parallel().tween_property(spr, "modulate", Color.WHITE, 0.2).set_ease(Tween.EASE_IN)

	_update_begin_button()


func _update_begin_button():
	begin_button.disabled = (selected_god == -1 or selected_leader == -1)
	if not begin_button.disabled:
		begin_button.text = "Begin Your Reign  →"


func _on_begin_pressed():
	GameData.selected_god  = selected_god
	GameData.selected_leader = selected_leader
	GameData.god_name      = GODS[selected_god]["name"]
	GameData.leader_name   = LEADERS[selected_leader]["name"]
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for i in range(leader_sprites.size()):
		if i == selected_leader:
			continue
		var spr: TextureRect = leader_sprites[i]
		var phase := i * 0.9
		var s := 1.0 + sin(t * 1.6 + phase) * 0.018
		spr.scale = Vector2(s, s)


func _add_separator(parent: VBoxContainer):
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0.3, 0.25, 0.45))
	parent.add_child(sep)
