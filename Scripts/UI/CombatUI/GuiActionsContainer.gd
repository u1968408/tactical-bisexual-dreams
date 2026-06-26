class_name GuiActionsContainer
extends Control

@export var actions: Array[Sprite2D]

var current_actions: int:
	get:
		return _current_actions
	set(value):
		var new: int = clampi(value, 0, max_actions)
		_current_actions = new
		for action_idx in range(max_actions):
			actions[action_idx].visible = action_idx < _current_actions

var max_actions: int:
	get:
		return len(actions)

var _current_actions: int
var _character: Character


func on_character_changed(character: Character) -> void:
	if _character != null and _character.actions_changed.is_connected(set_current_actions):
		_character.actions_changed.disconnect(set_current_actions)
	_character = character
	if _character == null:
		return

	set_current_actions(_character.current_actions)
	if not _character.actions_changed.is_connected(set_current_actions):
		_character.actions_changed.connect(set_current_actions)


func set_current_actions(current: int):
	current_actions = current


func replenish():
	_current_actions = max_actions
	for action in actions:
		action.visible = true


func spend():
	var act_idx: int = _current_actions - 1
	if act_idx < 0:
		return
	var current: Sprite2D = actions[act_idx]
	current.visible = false
