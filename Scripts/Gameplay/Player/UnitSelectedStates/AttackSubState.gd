extends UnitSubState
class_name AttackSubState


func _PrepareRange() -> void:
	generator.use_astar = false
	generator.GenerateTilesArroundPosition(
		character.board_position,
		character.stats.attack_range
	)

func OnMouseClick() -> void:
	var tile := hoovered_tile
	if tile and tile.current_entity != null:
		character.attack.Attack(tile.current_entity)
		master_state.ReturnToSelectState()
		return
	print("No attack target!")
