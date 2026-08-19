class_name CameraMovement
extends CameraComponent


## La velocitat màxima que pot assolir la càmera.
@export var speed: float = 100.0


var _direction := Vector2.ZERO

@onready var _board: Board = Board.instance


func _ready() -> void:
	InputController.camera_moved.connect(on_camera_direction_changed)


func _exit_tree() -> void:
	if not is_instance_valid(InputController):
		return

	InputController.camera_moved.disconnect(
		on_camera_direction_changed
	)


func _physics_process(delta: float) -> void:
	if _direction.is_zero_approx():
		return

	var move := _get_move_direction()
	var desired_movement := move * speed * delta

	var allowed_movement := _get_allowed_movement(
		desired_movement
	)

	if allowed_movement.is_zero_approx():
		return

	camera.global_position += allowed_movement


func on_camera_direction_changed(
	new_direction: Vector2
) -> void:
	_direction = new_direction


func _get_move_direction() -> Vector3:
	var aspect := camera.viewport_aspect

	var move_value := Vector3(
		-_direction.x * aspect.y,
		0.0,
		-_direction.y * aspect.x
	)

	return move_value.rotated(
		Vector3.UP,
		camera.rotation.y
	).normalized()


func _get_allowed_movement(
	desired_movement: Vector3
) -> Vector3:
	var current_look_position := camera.look_point

	var desired_look_position := (
		current_look_position + desired_movement
	)

	if _board.is_position_inside(desired_look_position):
		return desired_movement

	return _board.get_clamped_movement(
		current_look_position,
		desired_movement
	)