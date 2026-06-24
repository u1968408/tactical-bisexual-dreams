extends State

@onready var game_manager: GameManager = get_parent().get_parent()


func enter():
	super()
	game_manager.player_controller.start_turn()
