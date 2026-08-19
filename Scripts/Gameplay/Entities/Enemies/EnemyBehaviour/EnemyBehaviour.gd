class_name EnemyBehaviour
extends Node

@export var state_machine: StateMachine
@export var initial_state: State

@onready var enemy: Enemy = get_parent()

var current_attack_plan: AttackPlan


func execute():
	state_machine.set_current_state(initial_state)


func finish():
	state_machine.set_current_state(null)
