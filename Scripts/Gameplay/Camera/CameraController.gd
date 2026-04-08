@tool
extends Camera3D
class_name CameraController

@export var orbit: CameraOrbit
@export var movement: CameraMovement

var look_direction: Vector3:
	get:
		return (global_basis * Vector3.FORWARD).normalized()

var look_point: Vector3:
	get:
		var look_dir: Vector3 = look_direction
		var k_value: float = global_position.y / look_dir.y 
		return global_position - k_value * look_dir
		
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		DebugDraw3D.draw_line(global_position, look_point)
		return
	_handler_input(delta)

func _handler_input(delta: float) -> void:
	if Input.is_action_pressed("camera_orbit_left"):
		orbit.orbit_left()
	if Input.is_action_pressed("camera_orbit_right"):
		orbit.orbit_right()
	var move_vector: Vector2 = Input.get_vector(
		"camera_move_left",
		"camera_move_right",
		"camera_move_down",
		"camera_move_up"
	)
	movement.move(move_vector)
	
