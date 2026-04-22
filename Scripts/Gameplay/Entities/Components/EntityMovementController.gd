extends Node
class_name EntityMovementController

enum MoveState { IDLE, FOLLOW }

signal movement_started
signal movement_ended

@export var speed: float = 8.0
@export var mass: float = 2.0
@export var slow_radius: float = 2.0

@onready var _entity: Entity = get_parent()

var _arrive_distance: float = 0.01
var _state: MoveState = MoveState.IDLE
var _path: PackedVector3Array
var _next_point: Vector3
var _velocity: Vector3 = Vector3.ZERO
var _board: Board:
	get: return Board.instance

func SetNewPath(path: PackedVector2Array) -> void:
	if path.is_empty(): return
	_path = PackedVector3Array()
	for tile_id in path:
		_path.append(_board.GetWorldPosition(tile_id))
	_next_point = _path[0]
	_state = MoveState.FOLLOW
	movement_started.emit()

func _process(delta: float) -> void:
	if _state != MoveState.FOLLOW:
		return
	var is_last_point: bool = _path.size() <= 1
	var arrived := _move_logic(_next_point, delta, is_last_point)
	if arrived:
		_path.remove_at(0)
		if _path.is_empty():
			_entity.global_position = _next_point
			_OnFinish()
		else:
			_next_point = _path[0]

func _OnFinish() -> void:
	_state = MoveState.IDLE
	_velocity = Vector3.ZERO
	movement_ended.emit()

func _move_logic(target: Vector3, delta: float, decelerate: bool) -> bool:
	var to_target := target - _entity.global_position
	to_target.y = 0
	
	var distance := to_target.length()
	var direction := to_target.normalized()

	var desired_velocity := direction * speed
	
	if decelerate and distance < slow_radius:
		desired_velocity *= (distance / slow_radius)
	
	var steering := desired_velocity - _velocity
	_velocity += (steering / mass)
	
	if _velocity.length() > 0.1:
		_update_snapped_rotation(direction)
	
	_entity.global_position += _velocity * delta
	
	return distance < _arrive_distance

func _update_snapped_rotation(direction: Vector3) -> void:
	var target_look_dir := Vector3.ZERO
	if absf(direction.x) > absf(direction.z):
		target_look_dir = Vector3(signf(direction.x), 0, 0)
	else:
		target_look_dir = Vector3(0, 0, signf(direction.z))
	if target_look_dir != Vector3.ZERO:
		_entity.look_at(_entity.global_position + target_look_dir, Vector3.UP)