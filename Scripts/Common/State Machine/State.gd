@abstract
class_name State
extends Node

@onready
var state_machine := _get_state_machine()

func _get_state_machine() -> StateMachine:
	var parent := get_parent()
	if parent is StateMachine:
		return parent
	push_error("El pare de %s no és una StateMachine (parent: %s)." % [name, parent.name])
	return null

func enter():
	add_listeners()

func exit():
	remove_listeners()

func _exit_tree():
	remove_listeners()

func add_listeners():
	pass

func remove_listeners():
	pass
