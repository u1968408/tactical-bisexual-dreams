class_name CameraMovement
extends CameraComponent

## La velocitat màxima que pot assolir la càmera.
@export var speed: float = 100

var _direction: Vector2 = Vector2.ZERO

@onready var _board: Board = Board.instance


func _physics_process(delta: float) -> void:
	if _direction == Vector2.ZERO:
		return
	var aspect := camera.viewport_aspect
	var move_value: Vector3 = Vector3(-_direction.x * aspect.y, 0, -_direction.y * aspect.x)
	move_value = move_value.rotated(Vector3.UP, camera.rotation.y)
	var new_pos: Vector3 = camera.global_position + move_value * speed * delta
	var new_look_pos: Vector3 = camera.look_point + move_value * speed * delta
	if _board.is_position_outside(new_look_pos):
		return
	camera.global_position = new_pos


func on_camera_direction_changed(new_direction: Vector2) -> void:
	_direction = new_direction
