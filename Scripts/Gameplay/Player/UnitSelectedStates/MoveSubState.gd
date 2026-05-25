extends UnitSubState
class_name MoveSubState

func AddListeners() -> void:
	super()
	character.movement.movement_ended.connect(
		_OnMovementEnded
	)

func RemoveListeners() -> void:
	super()
	if character == null: return
	character.movement.movement_ended.disconnect(
		_OnMovementEnded
	)

func _PrepareRange():
	generator.GenerateTilesArroundPosition(
		character.board_position,
		character.stats.movement
	)

func OnMouseClick() -> void:
	var tile := hoovered_tile
	if tile == null or tile.current_entity != null:
		print("Clicked on entity")
	var path := generator.GetPathForTile(tile)
	character.Move(path)
	master_state.can_interact = false

func _OnMovementEnded():
	master_state.ReturnToSelectState()
