extends State

@onready
var game_manager: GameManager = get_parent().get_parent()

func Enter():
	super()
	game_manager.player_controller.StartTurn()
