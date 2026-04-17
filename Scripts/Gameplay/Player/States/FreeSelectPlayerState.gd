extends PlayerBaseState
class_name FreeSelectPlayerState

@export var pick_entity_state: UnitSelectedState

var _indicator_scene: PackedScene = load("uid://3g26356lwewc")
var _indicator: Indicator



func Enter():
	super()
	_indicator = _indicator_scene.instantiate()
	board.add_child(_indicator)

func Exit():
	super()
	_indicator.queue_free()
	print("Exited Free Select")

func on_mouse_move(_screen_position: Vector2, tile_position: Vector3):
	if _indicator != null: 
		_indicator.Move(tile_position)

func on_mouse_click() -> void:
	var entity := _indicator._current_entity
	if entity != null:
		pick_entity_state.current_entity = entity
		state_machine.setCurrentState(pick_entity_state)
