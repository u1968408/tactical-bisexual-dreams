class_name MoveSubState
extends UnitSubState


func enter() -> void:
	super()
	master_state.can_interact = true


func add_listeners() -> void:
	super()
	character.movement.movement_ended.connect(_reset_if_possible)


func remove_listeners() -> void:
	super()
	if character == null:
		return
	character.movement.movement_ended.disconnect(_reset_if_possible)


func prepare_range():
	generator.generate_tiles_arround_position(character.board_position, character.stats.movement)


func on_mouse_click() -> void:
	var tile := hoovered_tile
	if tile == null or tile.current_entity != null:
		print("Clicked on entity")
	var path := generator.get_path_for_tile(tile)
	character.use_action()
	character.move(path)
	master_state.can_interact = false
