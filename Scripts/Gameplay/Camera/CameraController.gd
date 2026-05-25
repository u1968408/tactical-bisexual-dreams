@tool
extends Camera3D
class_name CameraController

@export var orbit: CameraOrbit
@export var movement: CameraMovement

@onready var input_controller: InputController = %InputController

#region Properties

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

var mouse_world_position: Vector3:
	get:
		var mousepos := get_viewport().get_mouse_position()
		return project_ray_origin(mousepos)

var mouse_look_position: Vector3:
	get:
		var mousepos := get_viewport().get_mouse_position()
		var look_dir: Vector3 = project_ray_normal(mousepos)
		var k_value: float = mouse_world_position.y / look_dir.y 
		return mouse_world_position - k_value * look_dir

#endregion

#region Overrides

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	input_controller.camera_orbit.connect(orbit.OrbitCamera)
	input_controller.camera_moved.connect(movement.OnCameraMoveDirectionChanged)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		DebugDraw3D.draw_line(global_position, look_point)
		return

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	if is_instance_valid(input_controller):
		if input_controller.camera_orbit.is_connected(orbit.OrbitCamera):
			input_controller.camera_orbit.disconnect(orbit.OrbitCamera)
		if input_controller.camera_moved.is_connected(movement.OnCameraMoveDirectionChanged):
			input_controller.camera_moved.disconnect(movement.OnCameraMoveDirectionChanged)
#endregion
