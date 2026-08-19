class_name BoardInput
extends Node

var _last_mouse_screen_position := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if InputController.is_input_blocked(InputController.InputBlock.BOARD_INTERACTION):
		return

	if event is InputEventMouseMotion:
		_last_mouse_screen_position = event.position
		return

	if event is InputEventMouseButton and not event.pressed:
		_handle_mouse_button(event)


func _process(_delta: float) -> void:
	if InputController.is_input_blocked(InputController.InputBlock.BOARD_INTERACTION):
		return

	_update_mouse_hover()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MouseButton.MOUSE_BUTTON_LEFT:
			InputController.mouse_click.emit()

		MouseButton.MOUSE_BUTTON_RIGHT:
			InputController.mouse_secondary_click.emit()


func _update_mouse_hover() -> void:
	var camera := get_viewport().get_camera_3d()

	if camera == null:
		return

	if not camera is CameraController:
		return

	var world_pointer := _get_world_pointer(camera as CameraController, _last_mouse_screen_position)

	var board: Board = Board.instance

	if board == null:
		return

	world_pointer.x += board.TILE_SIZE.x / 2.0
	world_pointer.z += board.TILE_SIZE.y / 2.0

	var tile_position = board.position_matched_to_tile(world_pointer)

	if tile_position == null:
		return

	InputController.mouse_hover.emit(_last_mouse_screen_position, tile_position)


func _get_world_pointer(camera: CameraController, mouse_position: Vector2) -> Vector3:
	var look_dir := camera.look_direction

	if is_zero_approx(look_dir.y):
		return Vector3.ZERO

	var screen_world_position := (camera.project_ray_origin(mouse_position))

	var k_value := screen_world_position.y / look_dir.y

	return screen_world_position - k_value * look_dir
