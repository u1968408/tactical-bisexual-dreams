class_name MoveSubState
extends UnitSubState


func add_listeners() -> void:
	super()
	character.movement.movement_ended.connect(_on_movement_ended)


func remove_listeners() -> void:
	super()
	if character == null:
		return
	character.movement.movement_ended.disconnect(_on_movement_ended)


func prepare_range():
	generator.generate_tiles_arround_position(character.board_position, character.stats.movement)


func on_mouse_click() -> void:
	var tile := hoovered_tile
	if tile == null or tile.current_entity != null:
		print("Clicked on entity")
	var path := generator.get_path_for_tile(tile)
	character.move(path)
	master_state.can_interact = false


func _on_movement_ended():
	master_state.return_to_select_state()
