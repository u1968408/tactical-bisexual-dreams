@abstract
extends Area3D
class_name Entity

@onready var board: Board = %Board

var board_position: Vector2i:
	get:
		return Board.PositionOnBoard(global_position)
