@abstract class_name Entity
extends Area3D

signal state_changed(state: EntityState)
signal actions_changed(current: int)

enum LookDirection {
	UP_LEFT,
	DOWN_RIGHT,
	UP_RIGHT,
	DOWN_LEFT,
}

enum EntityState {
	IDLE,
	MOVING,
	ATTACKING,
}

const MAX_ACTIONS: int = 3

@export var movement: EntityMovementController
@export var weapons: Weapons
@export var stats: Stats
@export var attack: AttackController

var current_actions: int:
	get:
		return _current_acctions
	set(value):
		_current_acctions = clampi(value, 0, MAX_ACTIONS)
		actions_changed.emit(_current_acctions)

var current_state: EntityState = EntityState.IDLE:
	get:
		return current_state
	set(value):
		current_state = value
		state_changed.emit(current_state)

var global_forward: Vector3:
	get:
		return -global_transform.basis.z

var look_direction_along_camera: LookDirection:
	get:
		var local_dir: Vector3 = (
			_camera.global_transform.basis.orthonormalized().inverse() * global_forward
		)
		if local_dir.z < 0:
			if local_dir.x > 0:
				return LookDirection.UP_RIGHT
			return LookDirection.UP_LEFT
		if local_dir.x > 0:
			return LookDirection.DOWN_RIGHT
		return LookDirection.DOWN_LEFT

var look_direction: LookDirection:
	set(value):
		match value:
			LookDirection.UP_RIGHT:
				rotation.y = 0
			LookDirection.UP_LEFT:
				rotation.y = PI / 2
			LookDirection.DOWN_LEFT:
				rotation.y = PI
			LookDirection.DOWN_RIGHT:
				rotation.y = PI * 3 / 2

var board: Board:
	get:
		return Board.instance

var board_position: Vector2i:
	get:
		return Board.world_to_tile_id(global_position)

var _current_acctions: int = MAX_ACTIONS

@onready var _camera: CameraController = get_viewport().get_camera_3d()


func _ready() -> void:
	movement.movement_started.connect(_on_move_start)
	movement.movement_ended.connect(_on_move_end)


func move(path: PackedVector2Array):
	var start := path[0]
	var end := path[-1]

	board.set_solid(start, false)
	board.set_solid(end, true)

	movement.set_new_path(path)


func look_at_direction(target_position: Vector3):
	var direction: Vector3 = target_position - global_position
	direction.y = 0
	direction = direction.normalized()
	if direction.length() < 0.01:
		return
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
	look_direction = look_dir


func reset_turn() -> void:
	current_actions = MAX_ACTIONS


func use_action() -> void:
	current_actions -= 1


func has_actions() -> int:
	return current_actions > 0


func _on_move_end():
	current_state = EntityState.IDLE


func _on_move_start():
	current_state = EntityState.MOVING
