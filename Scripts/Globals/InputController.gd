extends Node

#region Signals

signal camera_moved(direction: Vector2)
signal camera_orbit(direction: CameraOrbit.OrbitDirection)

signal mouse_hover(screen_position: Vector2, tile_position: Vector3)
signal mouse_click
signal mouse_secondary_click

signal combat_ui_direction(direction: int)
signal combat_ui_by_id(id: int)

#endregion

#region Input Blocks

enum InputBlock {
	CAMERA_MOVEMENT,
	CAMERA_ORBIT,
	BOARD_INTERACTION,
	COMBAT,
	ALL,
}

var _input_blocks: Dictionary = {
	InputBlock.CAMERA_MOVEMENT: { },
	InputBlock.CAMERA_ORBIT: { },
	InputBlock.BOARD_INTERACTION: { },
	InputBlock.ALL: { },
}


func lock_input(block: InputBlock, lock_owner: Object) -> void:
	if lock_owner == null:
		push_warning("InputController.lock_input() requires a valid lock_owner.")
		return

	_input_blocks[block][lock_owner] = true


func unlock_input(block: InputBlock, lock_owner: Object) -> void:
	if lock_owner == null:
		return

	_input_blocks[block].erase(lock_owner)


func is_input_blocked(block: InputBlock) -> bool:
	if not _input_blocks[block].is_empty():
		return true

	if not _input_blocks[InputBlock.ALL].is_empty():
		return true

	return false


func clear_input_locks(lock_owner: Object) -> void:
	if lock_owner == null:
		return

	for block in _input_blocks:
		_input_blocks[block].erase(lock_owner)

#endregion

func _exit_tree() -> void:
	_input_blocks.clear()
