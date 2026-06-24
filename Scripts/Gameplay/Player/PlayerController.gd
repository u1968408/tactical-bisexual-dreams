class_name PlayerController
extends Node

@export var state_machine: StateMachine
@export var initial_state: State


func start_turn():
	state_machine.setCurrentState(initial_state)
