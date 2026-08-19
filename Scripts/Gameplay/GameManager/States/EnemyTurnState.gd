extends GameState

@export var next_state: GameState

var _current_enemy: Enemy


func enter():
	super()
	for enemy in enemies:
		enemy.reset_turn()
	player_ui.enemy_in()
	for enemy in enemies:
		camera.pan_to(enemy.board_position)
		await camera.pan_finished
		camera.follow.follow(enemy)
		print("Execuiting %s turn." % enemy.name)
		enemy.execute_turn()
		await enemy.turn_finished
		print("Finished %s turn." % enemy.name)
		camera.follow.stop_follow()
	state_machine.set_current_state(next_state)


func _next_enemy():
	if _current_enemy and _current_enemy.turn_finished.is_connected(_next_enemy):
		_current_enemy.turn_finished.disconnect(_next_enemy)
