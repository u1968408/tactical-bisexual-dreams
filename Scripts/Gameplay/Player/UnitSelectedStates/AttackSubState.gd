class_name AttackSubState
extends UnitSubState


func prepare_range() -> void:
	generator.use_astar = false
	generator.generate_tiles_arround_position(
		character.board_position, character.stats.attack_range
	)


func on_mouse_click() -> void:
	var tile := hoovered_tile
	if tile and tile.current_entity != null:
		character.attack.attack(tile.current_entity)
		character.use_action()
		_reset_if_possible()
	print("No attack target!")
