class_name HabilitiesSubState
extends UnitSubState


func enter():
	super()


func exit():
	super()
	character.habilities.cancel_current_hability()


func add_listeners():
	character.hability_finished.connect(master_state.return_to_move_state)


func remove_listeners():
	if character:
		character.hability_finished.disconnect(master_state.return_to_move_state)


func prepare_range() -> void:
	pass


func on_mouse_move(_screen_position: Vector2, _world_position: Vector3) -> void:
	var tile := master_state.current_tile
	if is_instance_valid(tile):
		character.habilities.on_tile_hover(master_state.current_tile)
	else:
		character.habilities.on_tile_hover(null)


func on_mouse_click() -> void:
	var tile := hoovered_tile
	character.habilities.clicked_tile(tile)
