class_name CombatUI
extends Control

signal action_changed(new: CombatUtils.Actions)

@export var portrait: TextureRect
@export var character_name: TextureRect
@export var actions_container: SelectableActions

var active: bool = false:
	get:
		return active
	set(value):
		active = value
		if not active:
			current_action = CombatUtils.Actions.NONE
			_animate_out()
		else:
			_animate_in()

var current_action: CombatUtils.Actions = CombatUtils.Actions.NONE:
	get:
		return current_action
	set(value):
		if value == current_action:
			return
		actions_container.select_action(value)
		print("Seting action %s [%s]" % [value, CombatUtils.Actions.find_key(value)])
		current_action = value
		action_changed.emit(value)

@onready var _character_name_pos: Vector2 = character_name.position


func _ready() -> void:
	InputController.combat_ui_direction.connect(on_change_direction)
	InputController.combat_ui_by_id.connect(on_change_by_id)
	visible = false


func _animate_in():
	visible = true
	character_name.global_position.x = -character_name.size.x
	var tween: Tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(character_name, "position", _character_name_pos, 0.15)
	tween.tween_property(portrait, "scale", Vector2.ONE, 0.15)
	tween.tween_property(actions_container, "scale", Vector2.ONE, 0.15)


func _animate_out():
	var tween: Tween = create_tween()
	tween.set_parallel(false)
	var new_pos_name = Vector2(-character_name.size.x, character_name.global_position.y)
	tween.tween_property(actions_container, "scale", Vector2.ZERO, 0.15)
	tween.tween_property(portrait, "scale", Vector2.ZERO, 0.15)
	tween.tween_property(character_name, "global_position", new_pos_name, 0.15)
	tween.finished.connect(func(): visible = false)


func on_change_direction(direction: int) -> void:
	if not active:
		return
	var new_index := wrapi(
		actions_container.current_index + direction, 0, len(actions_container.actions)
	)
	current_action = actions_container.actions[new_index].type
	print("Changed to %s" % current_action)


func on_change_by_id(id: int) -> void:
	if not active or id == 0:
		return
	if not id in CombatUtils.Actions.values():
		push_error("S'ha intentat habilitar un CombatUtils.Actions que no existeix (%s)." % id)
		return
	current_action = id as CombatUtils.Actions
