class_name CameraOrbit
extends CameraComponent

enum OrbitDirection {
	LEFT = -1,
	RIGHT = 1,
}

const ORBIT_CAMERA_ROTATION: float = TAU / 4

@export var rotation_time: float = 0.5

var _tween: Tween


func _ready() -> void:
	InputController.camera_orbit.connect(orbit_camera)


func _exit_tree() -> void:
	if not is_instance_valid(InputController):
		return
	if InputController.camera_orbit.is_connected(orbit_camera):
		InputController.camera_orbit.disconnect(orbit_camera)


func orbit_left():
	orbit_camera(OrbitDirection.LEFT)


func orbit_right():
	orbit_camera(OrbitDirection.RIGHT)


func orbit_camera(direction: OrbitDirection) -> void:
	if _tween:
		return

	InputController.lock_input(InputController.InputBlock.CAMERA_ORBIT, self)

	var center := camera.look_point
	var start_pos := camera.global_position
	var angle_to_rotate := ORBIT_CAMERA_ROTATION * direction

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_method(
		_animate_orbit.bind(start_pos, center, angle_to_rotate),
		0.0,
		1.0,
		rotation_time,
	)
	_tween.finished.connect(_finish_orbit)


func _finish_orbit() -> void:
	_tween = null

	InputController.unlock_input(InputController.InputBlock.CAMERA_ORBIT, self)


func _animate_orbit(progress: float, start_pos: Vector3, center: Vector3, total_angle: float):
	var current_angle := total_angle * progress
	var offset := start_pos - center
	var rotated_offset := offset.rotated(Vector3.UP, current_angle)
	camera.global_position = center + rotated_offset
	camera.look_at(center)
