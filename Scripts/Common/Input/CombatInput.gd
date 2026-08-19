class_name CombatInput
extends Node


func _unhandled_input(event: InputEvent) -> void:
	if InputController.is_input_blocked(InputController.InputBlock.BOARD_INTERACTION):
		return

	if event.is_action_pressed("combat_select_up"):
		InputController.combat_ui_direction.emit(-1)

	elif event.is_action_pressed("combat_select_down"):
		InputController.combat_ui_direction.emit(1)

	elif event.is_action_pressed("combat_select_1"):
		InputController.combat_ui_by_id.emit(1)

	elif event.is_action_pressed("combat_select_2"):
		InputController.combat_ui_by_id.emit(2)

	elif event.is_action_pressed("combat_select_3"):
		InputController.combat_ui_by_id.emit(3)
