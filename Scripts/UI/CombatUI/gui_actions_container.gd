extends Sprite2D

@export var actions: Array[Sprite2D]

var _current_actions


func _ready() -> void:
	replenish()


func replenish():
	_current_actions = len(actions)
	for action in actions:
		action.visible = true


func spend():
	var act_idx: int = _current_actions - 1
	if act_idx < 0:
		return
	var current: Sprite2D = actions[act_idx]
	current.visible = false
