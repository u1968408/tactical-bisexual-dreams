extends CameraComponent
class_name CameraMovement

@export
var speed: float = 1
	

func Move(movement: Vector2) -> void:
	if movement == Vector2.ZERO:
		return
	var aspect := camera.viewport_aspect
	var move_value: Vector3 = Vector3(
		-movement.x * aspect.y,
		0,
		-movement.y * aspect.x
	)
	move_value = move_value.rotated(Vector3.UP, camera.rotation.y)
	move_value *= speed
	camera.global_position += move_value

