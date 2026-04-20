extends Node
class_name InputController

@onready
var _camera: CameraController = get_viewport().get_camera_3d()
var _last_mouse_screen_pos: Vector2 = Vector2.ZERO

#region Signals
signal camera_moved(direction: Vector2)
signal camera_orbit(direction: CameraOrbit.OrbitDirection)

signal mouse_hover(screen_position: Vector2, tile_position: Vector3)
signal mouse_click
signal mouse_secondary_click
#endregion

#region Overrides
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_screen_pos = event.position
		_update_mouse_hover()
	elif event is InputEventMouseButton and not event.pressed:
		var btn_evt: InputEventMouseButton = event 
		if btn_evt.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			mouse_click.emit()
		elif btn_evt.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			mouse_secondary_click.emit()

func _process(delta: float) -> void:
	_handler_input_camera(delta)
	_update_mouse_hover()
#endregion

#region Private Methods
func _handler_input_camera(_delta: float) -> void:
	if Input.is_action_pressed("camera_orbit_left"):
		camera_orbit.emit(CameraOrbit.OrbitDirection.LEFT)
	if Input.is_action_pressed("camera_orbit_right"):
		camera_orbit.emit(CameraOrbit.OrbitDirection.RIGHT)
	var move_vector: Vector2 = Input.get_vector(
		"camera_move_left",
		"camera_move_right",
		"camera_move_down",
		"camera_move_up"
	)
	camera_moved.emit(move_vector)

func _get_world_pointer(mouse_position: Vector2) -> Vector3:
	var look_dir: Vector3 = _camera.look_direction
	if is_zero_approx(look_dir.y):
		return Vector3.ZERO
	var screen_world_position: Vector3 = _camera.project_ray_origin(mouse_position)
	var k_value: float = screen_world_position.y / look_dir.y
	var world_point: Vector3 = screen_world_position - k_value * look_dir
	return world_point

func _update_mouse_hover() -> void:
	var world_pointer := _get_world_pointer(_last_mouse_screen_pos)
	var board: Board = %Board
	world_pointer.x += board.TILE_SIZE.x / 2
	world_pointer.z += board.TILE_SIZE.y / 2
	var tile_id_pos: Variant = board.PositionMatchedToTile(world_pointer)
	if tile_id_pos == null:
		return
	mouse_hover.emit(
		_last_mouse_screen_pos,
		tile_id_pos
	)
#endregion
