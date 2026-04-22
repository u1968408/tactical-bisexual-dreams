@abstract
extends Area3D
class_name Entity

signal state_changed(state: EntityState)

@export var animation: AnimationController
@export var movement: EntityMovementController

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

var look_direction_along_camera: LookDirection:
	get:
# 1. Obtenemos la dirección hacia la que mira la entidad en el mundo (Global)
		# En Godot, el frente suele ser el eje -Z de su base
		var global_forward: Vector3 = -global_transform.basis.z
		
		# 2. Transformamos esa dirección al espacio local de la cámara
		# Esto nos dice cómo se ve ese "frente" desde los ojos de la cámara
		var local_dir: Vector3 = _camera.global_transform.basis.orthonormalized().inverse() * global_forward
		
		# 3. Analizamos los ejes X y Z locales de la cámara
		# local_dir.x > 0 -> Derecha de la pantalla
		# local_dir.x < 0 -> Izquierda de la pantalla
		# local_dir.z > 0 -> Hacia la cámara (Abajo en pantalla)
		# local_dir.z < 0 -> Lejos de la cámara (Arriba en pantalla)
		
		if local_dir.z < 0: # Caso UP
			if local_dir.x > 0:
				return LookDirection.UP_RIGHT
			else:
				return LookDirection.UP_LEFT
		else: # Caso DOWN
			if local_dir.x > 0:
				return LookDirection.DOWN_RIGHT
			else:
				return LookDirection.DOWN_LEFT

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

