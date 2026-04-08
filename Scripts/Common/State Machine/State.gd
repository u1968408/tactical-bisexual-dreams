@abstract
class_name State
extends Node

func Enter():
	AddListeners()

func Exit():
	RemoveListeners()

func _exit_tree():
	RemoveListeners()

@abstract
func AddListeners()

@abstract
func RemoveListeners()
