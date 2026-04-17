extends CameraComponent
class_name CameraOrbit

@export
var rotation_time: float = 0.5

var _rotating: bool = false

const ORBIT_CAMERA_ROTATION: float = TAU / 4

enum OrbitDirection {
	LEFT= -1,
	RIGHT= 1,
}

func OrbitLeft():
	OrbitCamera(OrbitDirection.LEFT)

func OrbitRight():
	OrbitCamera(OrbitDirection.RIGHT)

func OrbitCamera(direction: OrbitDirection) -> void:
	if _rotating:
		return
	_rotating = true
	
	var center := camera.look_point
	var start_pos := camera.global_position
	var angle_to_rotate := ORBIT_CAMERA_ROTATION * direction
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(
		_animate_orbit.bind(start_pos, center, angle_to_rotate),
		0.0, 
		1.0, 
		rotation_time
	)
	tween.finished.connect(func(): _rotating = false)
	
func _animate_orbit(progress: float, start_pos: Vector3, center: Vector3, total_angle: float):
	var current_angle := total_angle * progress
	var offset := start_pos - center
	var rotated_offset := offset.rotated(Vector3.UP, current_angle)
	camera.global_position = center + rotated_offset
	camera.look_at(center)
