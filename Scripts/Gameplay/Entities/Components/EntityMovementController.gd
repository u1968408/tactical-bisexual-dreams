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

	var direction := target - current
	direction.y = 0

	if direction.length() > 0.01:
		_update_snapped_rotation(direction.normalized())

	if next.distance_to(target) <= arrive_distance:
		entity.global_position = target
		_path.remove_at(0)

		if _path.is_empty():
			_finish()


func _finish() -> void:
	_state = MoveState.IDLE
	movement_ended.emit()


func _update_snapped_rotation(direction: Vector3) -> void:
	var look_dir: Entity.LookDirection = Entity.LookDirection.DOWN_LEFT
	if absf(direction.x) > absf(direction.z):
		if signf(direction.x) == -1:
			look_dir = Entity.LookDirection.UP_LEFT
		if signf(direction.x) == 1:
			look_dir = Entity.LookDirection.DOWN_RIGHT
	else:
		if signf(direction.z) == -1:
			look_dir = Entity.LookDirection.UP_RIGHT
		if signf(direction.z) == 1:
			look_dir = Entity.LookDirection.DOWN_LEFT
	entity.look_direction = look_dir
