class_name BaseCampDecorationSpawner
extends RefCounted

const TREE_COUNT := 55
const ROCK_COUNT := 18
const TREE_CLEARANCE := 110.0
const ROCK_TREE_CLEARANCE := 80.0
const ROCK_CLEARANCE := 90.0
const MAP_EDGE_PADDING := 80.0
const SHELTER_TREE_CLEARANCE := 320.0
const SHELTER_ROCK_CLEARANCE := 300.0
const TREE_BLOCK_RADIUS := 70.0
const ROCK_BLOCK_RADIUS := 50.0

const TREE_TEXTURES := [
	"res://assets/environment/Comp15.png",
	"res://assets/environment/Comp16.png",
]
const ROCK_TEXTURE := "res://assets/environment/Comp17.png"


static func scatter(
	world: Node2D,
	rng: RandomNumberGenerator,
	map_size: Vector2,
	protected_pos: Vector2,
	blocked_zones: Array
) -> void:
	var tree_positions := _scatter_trees(world, rng, map_size, protected_pos, blocked_zones)
	_scatter_rocks(world, rng, map_size, protected_pos, tree_positions, blocked_zones)


static func _scatter_trees(
	world: Node2D,
	rng: RandomNumberGenerator,
	map_size: Vector2,
	protected_pos: Vector2,
	blocked_zones: Array
) -> Array:
	var placed: Array = []
	var attempts := 0
	while placed.size() < TREE_COUNT and attempts < 2000:
		attempts += 1
		var pos := _random_map_pos(rng, map_size)
		if pos.distance_to(protected_pos) < SHELTER_TREE_CLEARANCE:
			continue
		if _is_too_close(pos, placed, TREE_CLEARANCE):
			continue
		placed.append(pos)
		_place_tree_sprite(world, pos, rng)
		blocked_zones.append({"pos": pos, "radius": TREE_BLOCK_RADIUS})
	return placed


static func _scatter_rocks(
	world: Node2D,
	rng: RandomNumberGenerator,
	map_size: Vector2,
	protected_pos: Vector2,
	tree_positions: Array,
	blocked_zones: Array
) -> void:
	var placed: Array = []
	var attempts := 0
	while placed.size() < ROCK_COUNT and attempts < 1000:
		attempts += 1
		var pos := _random_map_pos(rng, map_size)
		if pos.distance_to(protected_pos) < SHELTER_ROCK_CLEARANCE:
			continue
		if _is_too_close(pos, tree_positions, ROCK_TREE_CLEARANCE):
			continue
		if _is_too_close(pos, placed, ROCK_CLEARANCE):
			continue
		placed.append(pos)
		_place_rock_sprite(world, pos, rng)
		blocked_zones.append({"pos": pos, "radius": ROCK_BLOCK_RADIUS})


static func _random_map_pos(rng: RandomNumberGenerator, map_size: Vector2) -> Vector2:
	return Vector2(
		rng.randf_range(MAP_EDGE_PADDING, map_size.x - MAP_EDGE_PADDING),
		rng.randf_range(MAP_EDGE_PADDING, map_size.y - MAP_EDGE_PADDING)
	)


static func _is_too_close(pos: Vector2, placed: Array, clearance: float) -> bool:
	for other_pos in placed:
		if pos.distance_to(other_pos) < clearance:
			return true
	return false


static func _place_tree_sprite(world: Node2D, pos: Vector2, rng: RandomNumberGenerator) -> void:
	var spr := Sprite2D.new()
	spr.texture = load(TREE_TEXTURES[rng.randi() % TREE_TEXTURES.size()])
	var scale_value := rng.randf_range(0.26, 0.36)
	spr.scale = Vector2(scale_value, scale_value)
	spr.flip_h = rng.randi() % 2 == 1
	spr.position = pos
	world.add_child(spr)


static func _place_rock_sprite(world: Node2D, pos: Vector2, rng: RandomNumberGenerator) -> void:
	var spr := Sprite2D.new()
	spr.texture = load(ROCK_TEXTURE)
	var scale_value := rng.randf_range(0.18, 0.26)
	spr.scale = Vector2(scale_value, scale_value)
	spr.flip_h = rng.randi() % 2 == 1
	spr.position = pos
	world.add_child(spr)
