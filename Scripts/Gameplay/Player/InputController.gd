extends Node
class_name InputController

@onready
var _camera: CameraController = get_viewport().get_camera_3d()

signal camera_moved(direction: Vector2)
signal camera_orbit(direction: CameraOrbit.OrbitDirection)

signal mouse_hover(screen_position: Vector2, tile_position: Vector3)
signal mouse_click

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var world_pointer := _get_world_pointer(event.position)
		mouse_hover.emit(
			event.position,
			Board.PositionMatchedToTile(world_pointer, false)
		)
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			mouse_click.emit()
		

func _process(delta: float) -> void:
	_handler_input_camera(delta)

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
	var screen_world_position: Vector3 = _camera.project_ray_origin(mouse_position)
	var k_value: float = screen_world_position.y / look_dir.y
	var world_point: Vector3 = screen_world_position - k_value * look_dir
	return world_point
