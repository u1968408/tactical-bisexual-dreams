class_name GameManager
extends Node

@export var state_machine: StateMachine

@export var initial_state: State

@export var player_controller: PlayerController


func _ready() -> void:
	start_round()


func start_round() -> void:
	state_machine.set_current_state(initial_state)
