@tool
class_name CameraController
extends Camera3D

@export var orbit: CameraOrbit
@export var movement: CameraMovement
@export var in_game: bool = true

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
	if not in_game:
		return
	InputController.camera_orbit.connect(orbit.orbit_camera)
	InputController.camera_moved.connect(movement.on_camera_direction_changed)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		DebugDraw3D.draw_line(global_position, look_point)
		return


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	if is_instance_valid(InputController):
		if InputController.camera_orbit.is_connected(orbit.orbit_camera):
			InputController.camera_orbit.disconnect(orbit.orbit_camera)
		if InputController.camera_moved.is_connected(movement.on_camera_direction_changed):
			InputController.camera_moved.disconnect(movement.on_camera_direction_changed)


#endregion


func pan_to(pos: Vector2):
	InputController.can_move_camera = false
	var pos3: Vector3 = Vector3(pos.x, 0.0, pos.y)
	var tween: Tween = create_tween()
	var offset: Vector3 = pos3 - look_point
	var new_pos: Vector3 = Vector3(
		position.x + offset.x,
		position.y,
		position.z + offset.z,
	)
	tween.tween_property(self, "position", new_pos, 0.3)
	tween.tween_callback(func(): InputController.can_move_camera = true)
