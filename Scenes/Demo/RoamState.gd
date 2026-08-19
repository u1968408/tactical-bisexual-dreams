extends State

@onready var game_manager: GameManager = get_parent().get_parent()


func enter():
	super()
	game_manager.player_controller.start_turn()


func exit():
	super()
	game_manager.player_controller.end_turn()


func add_listeners():
	pass


func remove_listeners():
	pass
