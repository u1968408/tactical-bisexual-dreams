@abstract
extends Area3D
class_name Entity

signal state_changed(state: EntityState)

@export var animation: AnimationController
@export var movement: EntityMovementController
@export var weapons: Weapons
@export var stats: Stats
@export var attack: AttackController

@onready var _camera: CameraController = get_viewport().get_camera_3d()

var current_state: EntityState = EntityState.Idle:
	get:
		return current_state
	set(value):
		current_state = value
		state_changed.emit(current_state)

enum LookDirection {
	UP_LEFT,
	UP_RIGHT,
	DOWN_LEFT,
	DOWN_RIGHT,
}

enum EntityState {
	Idle,
	Moving,
	Attacking,
}

var global_forward: Vector3:
	get:
		return -global_transform.basis.z

var look_direction_along_camera: LookDirection:
	get:
		var local_dir: Vector3 = _camera.global_transform.basis.orthonormalized().inverse() * global_forward
		if local_dir.z < 0:
			if local_dir.x > 0:
				return LookDirection.UP_RIGHT
			else:
				return LookDirection.UP_LEFT
		else:
			if local_dir.x > 0:
				return LookDirection.DOWN_RIGHT
			else:
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
	get: return Board.instance

var board_position: Vector2i:
	get:
		return Board.WorldToTileID(global_position)

func _ready() -> void:
	movement.movement_started.connect(_OnMoveStart)
	movement.movement_ended.connect(_OnMoveEnd)

func Move(path: PackedVector2Array):
	var start := path[0]
	var end := path[-1]
	
	board.SetSolid(start, false)
	board.SetSolid(end, true)
	
	movement.SetNewPath(path)

func _OnMoveEnd():
	current_state = EntityState.Idle

func _OnMoveStart():
	current_state = EntityState.Moving

