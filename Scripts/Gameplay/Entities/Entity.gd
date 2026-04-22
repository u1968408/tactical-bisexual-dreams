@abstract
extends Area3D
class_name Entity

@export var movement: EntityMovementController

var board: Board:
	get: return Board.instance

var board_position: Vector2i:
	get:
		return Board.WorldToTileID(global_position)

func Move(path: PackedVector2Array):
	var start := path[0]
	var end := path[-1]
	
	board.SetSolid(start, false)
	board.SetSolid(end, true)
	
	movement.SetNewPath(path)
