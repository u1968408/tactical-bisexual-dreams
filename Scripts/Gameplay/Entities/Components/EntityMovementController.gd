class_name EntityMovementController
extends EntityNode

signal movement_started
signal movement_ended

enum MoveState { IDLE, FOLLOW }

@export var speed: float = 8.0
@export var arrive_distance: float = 0.05

var _state: MoveState = MoveState.IDLE
var _path: PackedVector3Array
var _board: Board:
	get:
		return Board.instance


func set_new_path(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
	_path = PackedVector3Array()
	for tile_id in path:
		_path.append(_board.get_world_position(tile_id))
	_state = MoveState.FOLLOW
	movement_started.emit()


func _physics_process(delta: float) -> void:
	if _state != MoveState.FOLLOW:
		return

	if _path.is_empty():
		_finish()
		return

	var target := _path[0]

	var current := entity.global_position
	var next := current.move_toward(target, speed * delta)

	entity.global_position = next

	entity.look_at_direction(target)

	if next.distance_to(target) <= arrive_distance:
		entity.global_position = target
		_path.remove_at(0)

		if _path.is_empty():
			_finish()


func _finish() -> void:
	_state = MoveState.IDLE
	movement_ended.emit()
