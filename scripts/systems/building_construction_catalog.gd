class_name BuildingConstructionCatalog
extends RefCounted

const TEMPLE_TIME := 300.0
const HALL_OF_DEVOTED_TIME := 7200.0
const PREACHER_SHELTER_TIME := 3600.0
const SHELTER_TIME := 1800.0
const ARMORY_TIME := 3600.0
const GARRISON_TIME := 3600.0
const GENERALS_QUARTERS_TIME := 3600.0
const DECORATION_TIME := 60.0

const DEFINITIONS := {
	"temple": {
		"label": "Small Temple",
		"time": TEMPLE_TIME,
	},
	"hall_of_devoted": {
		"label": "Hall of the Devoted",
		"time": HALL_OF_DEVOTED_TIME,
	},
	"preacher_shelter": {
		"label": "Preacher Shelter",
		"time": PREACHER_SHELTER_TIME,
	},
	"shelter": {
		"label": "Believer Shelter",
		"time": SHELTER_TIME,
	},
	"armory": {
		"label": "Barracks",
		"time": ARMORY_TIME,
	},
	"garrison": {
		"label": "Garrison",
		"time": GARRISON_TIME,
	},
	"generals_quarters": {
		"label": "General's Quarters",
		"time": GENERALS_QUARTERS_TIME,
	},
	"well": {
		"label": "Wishing Well",
		"time": DECORATION_TIME,
	},
	"garden": {
		"label": "Pumpkin Garden",
		"time": DECORATION_TIME,
	},
	"stone_pool": {
		"label": "Stone Pool",
		"time": DECORATION_TIME,
	},
}


static func get_definition(type: String) -> Dictionary:
	return DEFINITIONS.get(type, {})


static func get_label(type: String) -> String:
	return get_definition(type).get("label", "")


static func get_time(type: String) -> float:
	return get_definition(type).get("time", 0.0)
