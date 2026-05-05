class_name RoadTiles
extends RefCounted

const TEXTURE_PATHS := {
	"road_h": "res://assets/roads/Comp_14- no bg.png",
	"road_v": "res://assets/roads/Comp_13- no bg.png",
	"road_corner": "res://assets/roads/Comp_12- no bg.png",
	"road_t": "res://assets/roads/Comp_11- no bg.png",
}

const SCALES := {
	"road_h": Vector2(200.0 / 512.0, 72.0 / 512.0),
	"road_v": Vector2(72.0 / 512.0, 200.0 / 512.0),
	"road_corner": Vector2(138.0 / 512.0, 138.0 / 512.0),
	"road_t": Vector2(196.0 / 512.0, 138.0 / 512.0),
}

const ROTATABLE_TYPES := ["road_corner", "road_t"]


static func texture(type: String) -> Texture2D:
	var path: String = TEXTURE_PATHS.get(type, "")
	if path.is_empty():
		return null
	return load(path)


static func apply_to_sprite(spr: Sprite2D, type: String, rotation_deg: int) -> void:
	spr.texture = texture(type)
	spr.scale = SCALES.get(type, Vector2.ONE)
	spr.rotation_degrees = float(rotation_deg)


static func make_sprite(type: String, position: Vector2, rotation_deg: int) -> Sprite2D:
	var spr := Sprite2D.new()
	apply_to_sprite(spr, type, rotation_deg)
	spr.position = position
	return spr


static func is_rotatable(type: String) -> bool:
	return ROTATABLE_TYPES.has(type)
