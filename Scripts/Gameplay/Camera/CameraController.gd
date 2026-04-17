@tool
extends Camera3D
class_name CameraController

@export var orbit: CameraOrbit
@export var movement: CameraMovement

@onready var input_controller: InputController = %InputController

func _ready() -> void:
	input_controller.camera_orbit.connect(orbit.OrbitCamera)
	input_controller.camera_moved.connect(movement.Move)
	
func _exit_tree() -> void:
	input_controller.camera_orbit.disconnect(orbit.OrbitCamera)
	input_controller.camera_moved.disconnect(movement.Move)

var viewport_aspect: Vector2:
	get:
		var viewport_rect := get_viewport().get_visible_rect()
		return Vector2(viewport_rect.size.x, viewport_rect.size.y).normalized()

var look_direction: Vector3:
	get:
		return (global_basis * Vector3.FORWARD).normalized()

var look_point: Vector3:
	get:
		var look_dir: Vector3 = look_direction
		var k_value: float = global_position.y / look_dir.y 
		return global_position - k_value * look_dir
		
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		DebugDraw3D.draw_line(global_position, look_point)
		return

