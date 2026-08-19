class_name CameraFollow
extends CameraComponent


@export var follow_speed: float = 10.0
@export var use_smoothing: bool = true


var _target: Node3D


func _physics_process(delta: float) -> void:
	if _target == null:
		return

	_update_follow(delta)


func follow(target: Node3D) -> void:
	if target == null:
		return

	if _target == target:
		return

	if _target == null:
		InputController.lock_input(
			InputController.InputBlock.CAMERA_MOVEMENT,
			self
		)

	_target = target


func stop_follow() -> void:
	if _target == null:
		return

	_target = null

	InputController.unlock_input(
		InputController.InputBlock.CAMERA_MOVEMENT,
		self
	)


func is_following() -> bool:
	return _target != null


func _update_follow(delta: float) -> void:
	if not is_instance_valid(_target):
		stop_follow()
		return

	var target_position := _get_target_position()
	var offset := target_position - camera.look_point

	offset.y = 0.0

	if use_smoothing:
		offset *= 1.0 - exp(-follow_speed * delta)
	else:
		pass

	camera.global_position += offset


func _get_target_position() -> Vector3:
	var target_position := _target.global_position

	return Vector3(
		target_position.x,
		0.0,
		target_position.z
	)