extends Node3D
class_name Board

const TILE_SIZE: Vector2 = Vector2(1, 1)


var _min := Vector2i(-10, -10)
var _max := Vector2i(10, 10)
var _position := Vector2i(0,0)

var tile_position: Vector2i:
	get:
		return _position
	set(new_value):
		_position = new_value

var min_tile: Vector2i:
	get:
		return _min

var max_tile: Vector2i:
	get:
		return _max
		
static func PositionMatchedToTile(other_position: Vector3, add_tile_offset: bool = true) -> Vector3:
	var recalculated_pos := other_position.round()
	if add_tile_offset:
		recalculated_pos.x += TILE_SIZE.x/2
		recalculated_pos.z += TILE_SIZE.y/2
	return recalculated_pos

static func PositionOnBoard(other_position: Vector3) -> Vector2i:
	var recalculated_pos := PositionMatchedToTile(other_position)
	return Vector2i(int(recalculated_pos.x), int(recalculated_pos.z))

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	

