class_name SelectableActions
extends Control

signal action_clicked(action: CombatUtils.Actions)
signal habilities_selected

@export var action_attack: SelectableAction
@export var action_habilites: SelectableAction
@export var action_move: SelectableAction

var enabled: bool:
	get:
		return _enabled
	set(value):
		_enabled = value
		for action in actions:
			if not _enabled:
				action.unselect()
			action.enabled = _enabled

var actions: Array[SelectableAction]:
	get:
		return [
			action_habilites,
			action_attack,
			action_move,
		]

var current_index: int:
	get:
		return actions.find_custom(func(act: SelectableAction): return act.is_selected)

var _enabled: bool = true


func _ready() -> void:
	for action in actions:
		action.finished_animation_select.connect(_on_finished_action_animation)


func _gui_input(event: InputEvent) -> void:
	if not enabled:
		return

	if event is not InputEventMouseButton:
		return

	var evt := event as InputEventMouseButton
	if evt.button_index != MOUSE_BUTTON_LEFT or not evt.is_released():
		return

	var viewport_mouse := get_viewport().get_mouse_position()
	var action := _get_action_at_viewport_point(viewport_mouse)

	if action == null:
		return

	action_clicked.emit(action.type)
	accept_event()


func select_action(type: CombatUtils.Actions):
	_on_select(type)


func _on_select(type: CombatUtils.Actions):
	var others: Array[SelectableAction] = _get_others(type)

	for other in others:
		other.unselect()

	if type == CombatUtils.Actions.NONE:
		return

	var current: SelectableAction = _get_from_type(type)
	current.select()


func _get_action_at_viewport_point(viewport_point: Vector2) -> SelectableAction:
	var best: SelectableAction = null

	for action in actions:
		if action == null:
			continue

		if not action.contains_viewport_point(viewport_point):
			continue

		# La última acción del array tiene prioridad si hay solape real.
		best = action

	return best


func _get_from_type(type: CombatUtils.Actions):
	var found = actions.find_custom(func(x: SelectableAction): return x.type == type)

	if found < 0:
		push_error(
			(
				"No s'ha trobat action %s[%s] a selectable_actions :("
				% [CombatUtils.Actions.keys()[type], type]
			)
		)
		return null

	return actions[found]


func _get_others(type: CombatUtils.Actions) -> Array[SelectableAction]:
	return actions.filter(func(x: SelectableAction): return x != null and x.type != type)


func _on_finished_action_animation(type: CombatUtils.Actions):
	if type == CombatUtils.Actions.HABILITIES:
		print("emitting type: %s" % type)
		habilities_selected.emit()
