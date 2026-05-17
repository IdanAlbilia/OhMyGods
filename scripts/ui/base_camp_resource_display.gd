extends RefCounted

var gold_label: Label = null
var faith_label: Label = null
var people_label: Label = null
var people_panel: PanelContainer = null
var people_detail_label: Label = null


func setup(refs: Dictionary) -> void:
	gold_label = refs.get("gold_label", null)
	faith_label = refs.get("faith_label", null)
	people_label = refs.get("people_label", null)
	people_panel = refs.get("people_panel", null)
	people_detail_label = refs.get("people_detail_label", null)


func refresh(gold: int, faith: int, believers_count: int, preachers_count: int, soldiers_count: int) -> void:
	if gold_label != null:
		gold_label.text = "Gold  %d" % gold

	if faith_label != null:
		faith_label.text = "Faith  %d" % faith

	if people_label != null:
		var total_people := believers_count + preachers_count + soldiers_count
		people_label.text = "People  %d" % total_people

	if people_panel != null and people_panel.visible:
		refresh_people_panel(believers_count, preachers_count, soldiers_count)


func refresh_people_panel(believers_count: int, preachers_count: int, soldiers_count: int) -> void:
	if people_detail_label == null:
		return

	people_detail_label.text = (
		"Believers:   %d\n" % believers_count +
		"Preachers:  %d\n" % preachers_count +
		"Soldiers:    %d" % soldiers_count
	)
