class_name CameraInput
extends Node


func _process(_delta: float) -> void:
	if not InputController.is_input_blocked(InputController.InputBlock.CAMERA_ORBIT):
		_handle_orbit()

	if not InputController.is_input_blocked(InputController.InputBlock.CAMERA_MOVEMENT):
		_handle_movement()


func _handle_orbit() -> void:
	if Input.is_action_pressed("camera_orbit_left"):
		InputController.camera_orbit.emit(CameraOrbit.OrbitDirection.LEFT)

	if Input.is_action_pressed("camera_orbit_right"):
		InputController.camera_orbit.emit(CameraOrbit.OrbitDirection.RIGHT)


func _handle_movement() -> void:
	var direction := Input.get_vector(
		"camera_move_left",
		"camera_move_right",
		"camera_move_down",
		"camera_move_up",
	)

	InputController.camera_moved.emit(direction)
