class_name FreeSelectPlayerState
extends PlayerBaseState

@export var pick_character_state: UnitSelectedState

var _indicator_scene: PackedScene = load("uid://3g26356lwewc")
var _indicator: Indicator


func enter():
	super()
	_indicator = _indicator_scene.instantiate()
	board.add_child(_indicator)


func exit():
	super()
	_indicator.queue_free()


func on_mouse_move(_screen_position: Vector2, tile_position: Vector3):
	if _indicator != null:
		_indicator.move(tile_position)


func on_mouse_click() -> void:
	var entity := _indicator._current_entity
	print("Clicked on %s" % _indicator.target_tile_id)
	if entity == null:
		return
	if entity is Character:
		pick_character_state.current_character = entity
		state_machine.set_current_state(pick_character_state)
