extends UnitSubState
class_name MoveSubState

func AddListeners() -> void:
	super()
	character.movement.movement_ended.connect(
		asdkpao
	)

func RemoveListeners() -> void:
	super()
	if character == null: return
	character.movement.movement_ended.disconnect(
		asdkpao
	)

func _prepare_range():
	generator.GenerateTilesArroundPosition(
		character.board_position,
		character.stats.movement
	)

func asdkpao():
	master_state.ReturnToSelectState()

func on_mouse_click():
	var tile := hoovered_tile
	if tile == null or tile.current_entity != null:
		print("Clicked on entity")
	var path := generator.GetPathForTile(tile)
	character.Move(path)
	master_state.can_interact = false
