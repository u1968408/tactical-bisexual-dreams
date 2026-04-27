extends UnitSubState
class_name AttackSubState


func _prepare_range():
	generator.GenerateTilesArroundPosition(
		character.board_position,
		character.stats.attack_range
	)

func on_mouse_click():
	var tile := hoovered_tile
	if tile and tile.current_entity != null:
		print("Attack %s" % tile.current_entity)
	print("No attack target!")
