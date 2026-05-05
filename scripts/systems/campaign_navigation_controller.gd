class_name CampaignNavigationController
extends RefCounted

const BaseCampStateScript: GDScript = preload("res://scripts/state/base_camp_state.gd")
const CAMPAIGN_SCENE := "res://scenes/campaign_map.tscn"


func start_new_campaign(game: Node) -> void:
	GameData.base_camp_state = BaseCampStateScript.capture(game)
	GameData.mission_active = false
	game.get_tree().change_scene_to_file(CAMPAIGN_SCENE)


func return_to_active_campaign(game: Node) -> void:
	GameData.base_camp_state = BaseCampStateScript.capture(game)
	game.get_tree().change_scene_to_file(CAMPAIGN_SCENE)


func is_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed
