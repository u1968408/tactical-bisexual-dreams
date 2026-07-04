class_name PlayerController
extends Node

@export var state_machine: StateMachine
@export var initial_state: State


func start_turn():
	state_machine.set_current_state(initial_state)


func end_turn():
	state_machine.set_current_state(null)
