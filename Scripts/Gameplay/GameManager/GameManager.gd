extends Node
class_name GameManager

@export
var state_machine: StateMachine

@export
var initial_state: State

@export
var player_controller: PlayerController

func _ready() -> void:
	StartRound()
	
func StartRound() -> void:
	state_machine.setCurrentState(initial_state)
