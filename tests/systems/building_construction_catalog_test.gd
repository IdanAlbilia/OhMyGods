extends SceneTree

const BuildingConstructionCatalogScript: GDScript = preload("res://scripts/systems/building_construction_catalog.gd")


func _init() -> void:
	_assert_definition("temple", "Small Temple", 300.0)
	_assert_definition("hall_of_devoted", "Hall of the Devoted", 7200.0)
	_assert_definition("preacher_shelter", "Preacher Shelter", 3600.0)
	_assert_definition("shelter", "Believer Shelter", 1800.0)
	_assert_definition("armory", "Barracks", 3600.0)
	_assert_definition("garrison", "Garrison", 3600.0)
	_assert_definition("generals_quarters", "General's Quarters", 3600.0)
	_assert_definition("well", "Wishing Well", 60.0)
	_assert_definition("garden", "Pumpkin Garden", 60.0)
	_assert_definition("stone_pool", "Stone Pool", 60.0)

	if BuildingConstructionCatalogScript.get_definition("missing").size() != 0:
		push_error("Unknown building types should return an empty definition.")
		quit(1)
		return

	print("Building construction catalog test passed.")
	quit(0)


func _assert_definition(type: String, label: String, time: float) -> void:
	if BuildingConstructionCatalogScript.get_label(type) != label:
		push_error("Expected %s label to be %s." % [type, label])
		quit(1)
	if not is_equal_approx(BuildingConstructionCatalogScript.get_time(type), time):
		push_error("Expected %s time to be %f." % [type, time])
		quit(1)
