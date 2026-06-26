class_name CombatUI
extends Control

signal action_changed(new: CombatUtils.Actions)
signal character_changed(character: Character)

@export var portrait: TextureRect
@export var character_name: GuiNameContainer
@export var selectable_actions: SelectableActions
@export var actions_container: GuiActionsContainer

var character: Character:
	get:
		return _character
	set(value):
		_character = value
		character_changed.emit(value)
		if value != null:
			portrait.texture = value.character_data.portrait
			print("Emited changed to character %s" % [value.name])

var active: bool:
	get:
		return _active
	set(value):
		_active = value
		if not _active:
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
		selectable_actions.select_action(value)
		current_action = value
		action_changed.emit(value)

var _character: Character
var _active: bool = false

@onready var _character_name_pos: Vector2 = character_name.position


func _ready() -> void:
	InputController.combat_ui_direction.connect(_on_change_direction)
	InputController.combat_ui_by_id.connect(_on_change_by_id)
	visible = false


## Activa la UI i mostra la info del personatge
func character_selected(selected_character: Character):
	if selected_character == null:
		character_unselected()
		return
	character = selected_character
	active = true


func character_unselected():
	active = false


func _animate_in():
	visible = true
	character_name.global_position.x = -character_name.size.x
	var tween: Tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(character_name, "position", _character_name_pos, 0.15)
	tween.tween_property(portrait, "scale", Vector2.ONE, 0.15)
	tween.tween_property(selectable_actions, "scale", Vector2.ONE, 0.15)


func _animate_out():
	var tween: Tween = create_tween()
	tween.set_parallel(false)
	var new_pos_name = Vector2(-character_name.size.x, character_name.global_position.y)
	tween.tween_property(selectable_actions, "scale", Vector2.ZERO, 0.15)
	tween.tween_property(portrait, "scale", Vector2.ZERO, 0.15)
	tween.tween_property(character_name, "global_position", new_pos_name, 0.15)
	tween.finished.connect(_on_out_finished)

func _on_out_finished():
	visible = false
	character = null

func _on_change_direction(direction: int) -> void:
	if not active:
		return
	var new_index := wrapi(
		selectable_actions.current_index + direction, 0, len(selectable_actions.actions)
	)
	current_action = selectable_actions.actions[new_index].type


func _on_change_by_id(id: int) -> void:
	if not active or id == 0:
		return
	if not id in CombatUtils.Actions.values():
		push_error("S'ha intentat habilitar un CombatUtils.Actions que no existeix (%s)." % id)
		return
	current_action = id as CombatUtils.Actions
