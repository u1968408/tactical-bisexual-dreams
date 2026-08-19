class_name FreeRoamState
extends PlayerBaseState

var _indicator_scene: PackedScene = load("uid://3g26356lwewc")
var _indicator: Indicator

@onready var _character: Character

var character: Character:
	get:
		return _character
	set(value):
		if value == _character:
			return
		if _character != null:
			_camera.follow.stop_follow()
			_character.monitorable = true
		_character = value
		_character.monitorable = false
		_camera.follow.follow(_character)

var _camera: CameraController:
	get:
		return get_viewport().get_camera_3d()


func enter():
	super()
	character = _find_character()
	_indicator = _indicator_scene.instantiate()
	board.add_child(_indicator)


func exit():
	super()
	_indicator.queue_free()


func add_listeners():
	super()


func remove_listeners():
	super()


func _find_character() -> Character:
	var entities := get_tree().get_nodes_in_group("Entity")
	for e in entities:
		if e is Character:
			return e as Character
	push_warning("No s'ha trobat cap personatge al Free Roam")
	return null


func on_mouse_move(_screen_position: Vector2, tile_position: Vector3):
	if _indicator != null:
		_indicator.move(tile_position)


func on_mouse_click() -> void:
	print(
		"Clicked on %s%s"
		% [
			_indicator.target_tile_id,
			" [solid]" if board.is_solid(_indicator.target_tile_id) else "",
		]
	)
	move_player_to(_indicator.tile_position)


func move_player_to(tile_position: Vector2i) -> void:
	var path := board.find_path(character.board_position, tile_position, -1)

	if path.is_empty():
		print("No path")
		return

	character.move(path, false)
