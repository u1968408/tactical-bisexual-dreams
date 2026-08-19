@tool
class_name CameraController
extends Camera3D

signal pan_finished

@export var orbit: CameraOrbit
@export var movement: CameraMovement
@export var follow: CameraFollow

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
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		DebugDraw3D.draw_line(global_position, look_point)
		return

#endregion

func pan_to(pos: Vector2):
	InputController.lock_input(InputController.InputBlock.CAMERA_MOVEMENT, self)
	var pos3: Vector3 = Vector3(pos.x, 0.0, pos.y)
	var tween: Tween = create_tween()
	var offset: Vector3 = pos3 - look_point
	var new_pos: Vector3 = Vector3(position.x + offset.x, position.y, position.z + offset.z)
	tween.tween_property(self, "position", new_pos, 0.3)
	tween.tween_callback(_on_pan_finished)

func _on_pan_finished():
	InputController.unlock_input(InputController.InputBlock.CAMERA_MOVEMENT, self)
	pan_finished.emit()
