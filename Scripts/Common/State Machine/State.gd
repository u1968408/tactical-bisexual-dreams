@abstract
class_name State
extends Node

@onready
var state_machine := __get_state_machine()

func __get_state_machine() -> StateMachine:
	var parent := get_parent()
	if parent is StateMachine:
		return parent
	push_error("El pare de %s no és una StateMachine (parent: %s)." % [name, parent.name])
	return null

func Enter():
	AddListeners()

func Exit():
	RemoveListeners()

func _exit_tree():
	RemoveListeners()

func AddListeners():
	pass

func RemoveListeners():
	pass
