class_name Collisions

enum Layers {
	ENEMIES = 2,
	CHARACTERS = 3,
	TERRAIN = 4,
	INDICATOR = 9,
}

static func _callable_has_layer(layer: Layers) -> Callable:
	return func(area: Area3D): return area.get_collision_layer_value(layer)

static func HasTerreainInList(areas: Array[Area3D]) -> bool:
	return areas.any(_callable_has_layer(Layers.TERRAIN))

static func HasCharactersInList(areas: Array[Area3D]) -> bool:
	return areas.any(_callable_has_layer(Layers.CHARACTERS))
	
static func HasEnemiesInList(areas: Array[Area3D]) -> bool:
	return areas.any(_callable_has_layer(Layers.ENEMIES))