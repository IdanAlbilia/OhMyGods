class_name TutorialCopy
extends RefCounted

const INTRO := 0
const BUILD_TEMPLE := 1
const PLACE_TEMPLE := 2
const RUSH_PROMPT := 3
const TEMPLE_COMPLETE := 4
const TAP_SHELTER := 5
const TAP_GO_PRAY := 6
const CHOOSE_BELIEVERS := 7
const COMPLETE := 8
const WHEEL_HINT := 9


static func speech(step: int, leader_name: String) -> String:
	match step:
		INTRO:
			return "Greetings, my lord! I am %s, your faithful guide.\n\nFive believers have pledged their lives to your cause. Together, we shall build an empire worthy of the gods!" % leader_name
		BUILD_TEMPLE:
			return "Your people are restless - they need a place to worship.\n\nBuild a Temple and they will pray, earning you Faith Points. Open the Build menu to begin!"
		PLACE_TEMPLE:
			return "Choose the perfect spot!\n\nTap anywhere on the map to place the Temple."
		RUSH_PROMPT:
			return "Patience is a virtue - but Faith is power!\n\nEach Faith Point shaves 10 minutes off construction. Give that Rush button a tap!"
		TEMPLE_COMPLETE:
			return "Magnificent! The Temple rises in your name.\n\nYour believers can now gather within its walls and pray."
		TAP_SHELTER:
			return "Time to put your people to work!\n\nTap the Humble Shelter to send your believers to pray at the Temple."
		TAP_GO_PRAY:
			return "Tap the Go Pray button, choose how many believers to send, then hit Send to Pray.\n\nThey will return after 30 minutes with faith in their hearts."
		CHOOSE_BELIEVERS:
			return ""
		COMPLETE:
			return "You've done it, my lord! Faith fuels everything - rush builds, unlock upgrades, and grow your empire.\n\nThe divine path lies open before you."
		WHEEL_HINT:
			return "One final gift before you go!\n\nThe Grand Priestess has prepared a divine miracle. Tap the Spin chip to claim your first blessing."
	return ""
