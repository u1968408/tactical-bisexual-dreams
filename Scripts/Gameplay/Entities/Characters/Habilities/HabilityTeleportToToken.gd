extends Hability

var _pos_objective: Vector2i


func clicked_tile(tile: Tile):
	_pos_objective = tile.tile_position
	generator = null
	InputController.lock_input(InputController.InputBlock.BOARD_INTERACTION, self)
	character.current_state = Entity.EntityState.TELEPORT


func _execute() -> void:
	pass


func on_hability_animation(animation_name: String):
	print("received in teleport hability anim: %s" % animation_name)
	if animation_name == "teleport":
		character.teleport(_pos_objective)
	elif animation_name == "finished_teleport":
		InputController.unlock_input(InputController.InputBlock.BOARD_INTERACTION, self)
		finished.emit(true)
