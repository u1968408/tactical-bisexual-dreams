extends GameState

@export var next_state: GameState


func enter():
	super()
	for character in characters:
		character.reset_turn()
	game_manager.player_controller.start_turn()
	player_ui.player_in()


func exit():
	super()
	game_manager.player_controller.end_turn()
	player_ui.player_out()


func add_listeners():
	player_ui.passed_turn.connect(_on_passed_turn)

func remove_listeners():
	player_ui.passed_turn.disconnect(_on_passed_turn)


func _on_passed_turn():
	state_machine.set_current_state(next_state)
