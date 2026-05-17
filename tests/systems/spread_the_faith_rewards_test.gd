extends SceneTree

const SpreadRewardsScript: GDScript = preload("res://scripts/systems/spread_the_faith_rewards.gd")


func _init() -> void:
	if SpreadRewardsScript.result_text(0, 0) != "The crowd was unmoved this time...\nYour preachers return to rest.":
		push_error("Empty spread result text should describe no converts.")
		quit(1)
		return

	if not SpreadRewardsScript.result_text(3, 1).contains("3 souls wished to join"):
		push_error("Capped spread result should mention full shelters.")
		quit(1)
		return

	if not SpreadRewardsScript.result_text(1, 1).contains("1 new soul"):
		push_error("Single joined spread result should use singular copy.")
		quit(1)
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var result: Dictionary = SpreadRewardsScript.resolve(rng, 8, 3)
	if result.joined > 3:
		push_error("Spread rewards should cap joined believers by available capacity.")
		quit(1)
		return
	if result.brought < result.joined:
		push_error("Spread rewards should not join more believers than were brought.")
		quit(1)
		return
	if str(result.text).is_empty():
		push_error("Spread rewards should include result text.")
		quit(1)
		return

	print("Spread the Faith rewards test passed.")
	quit(0)
