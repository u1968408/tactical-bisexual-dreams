@abstract class_name Entity
extends Area3D

signal state_changed(state: EntityState)

enum LookDirection {
	UP_LEFT,
	UP_RIGHT,
	DOWN_LEFT,
	DOWN_RIGHT,
}

enum EntityState {
	IDLE,
	MOVING,
	ATTACKING,
}

@export var animation: AnimationController
@export var movement: EntityMovementController
@export var weapons: Weapons
@export var stats: Stats
@export var attack: AttackController

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


func _on_move_end():
	current_state = EntityState.IDLE


func _on_move_start():
	current_state = EntityState.MOVING
