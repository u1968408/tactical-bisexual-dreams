extends Node
class_name PlayerController

@export
var state_machine: StateMachine
@export
var initial_state: State

func StartTurn():
	state_machine.setCurrentState(initial_state)
	
