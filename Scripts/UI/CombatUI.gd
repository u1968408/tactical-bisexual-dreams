class_name CombatUI
extends Control

signal action_changed(new: CombatUtils.Actions)
signal character_changed(character: Character)

@export var portrait: TextureRect
@export var character_name: GuiNameContainer
@export var selectable_actions: SelectableActions
@export var actions_container: GuiActionsContainer
@export var stats_container: GuiStatsContainer
@export var weapon_container: GuiWeaponMarker
@export var habilites_container: GuiHabilitiesContainer

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
		stats_container.active = value
		habilites_container.active = false
		if not _active:
			current_action = CombatUtils.Actions.NONE
			_animate_out()
		else:
			_animate_in()

var current_action: CombatUtils.Actions:
	get:
		return _current_action
	set(value):
		if value == _current_action:
			return
		if not selectable_actions.enabled:
			_current_action = CombatUtils.Actions.NONE
			return
		if (
			_current_action == CombatUtils.Actions.HABILITIES
			and value != CombatUtils.Actions.HABILITIES
		):
			_animate_selectable_actions()
			habilites_container.active = false
		_current_action = value

		selectable_actions.select_action(value)
		action_changed.emit(value)

var _character: Character
var _active: bool = false
var _tween: Tween
var _current_action: CombatUtils.Actions = CombatUtils.Actions.NONE

@onready var _character_name_pos: Vector2 = character_name.position


func _ready() -> void:
	InputController.combat_ui_direction.connect(_on_change_direction)
	InputController.combat_ui_by_id.connect(_on_change_by_id)
	selectable_actions.action_clicked.connect(_on_select_by_type)
	selectable_actions.habilities_selected.connect(_on_habilities_selected)
	visible = false


## Activa la UI i mostra la info del personatge
func character_selected(selected_character: Character):
	if character != null and character.actions_changed.is_connected(_on_actions_changed):
		character.actions_changed.disconnect(_on_actions_changed)
	if selected_character == null:
		character_unselected()
		return
	character = selected_character
	selectable_actions.enabled = character.has_actions()
	if not character.actions_changed.is_connected(_on_actions_changed):
		character.actions_changed.connect(_on_actions_changed)
	active = true


func character_unselected():
	active = false


func _on_actions_changed(current_actions: int):
	selectable_actions.enabled = current_actions > 0


func _animate_in():
	visible = true
	character_name.global_position.x = -character_name.size.x
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(false)
	weapon_container.scale = Vector2.ONE
	actions_container.scale = Vector2.ONE
	_tween.tween_property(character_name, "position", _character_name_pos, 0.15)
	_tween.tween_property(portrait, "scale", Vector2.ONE, 0.15)
	_tween.tween_property(selectable_actions, "scale", Vector2.ONE, 0.15)


func _animate_out():
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(false)
	var new_pos_name = Vector2(-character_name.size.x, character_name.global_position.y)
	_tween.tween_property(selectable_actions, "scale", Vector2.ZERO, 0.15)
	_tween.tween_property(portrait, "scale", Vector2.ZERO, 0.15)
	_tween.tween_property(character_name, "global_position", new_pos_name, 0.15)
	_tween.finished.connect(_on_out_finished)


func _on_habilities_selected():
	_animate_selectable_actions(true)


func _animate_selectable_actions(out: bool = false):
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	var new_scale: Vector2 = Vector2.ZERO if out else Vector2.ONE
	_tween.tween_property(selectable_actions, "scale", new_scale, 0.25)
	_tween.tween_property(actions_container, "scale", new_scale, 0.25)
	_tween.tween_property(weapon_container, "scale", new_scale, 0.25)
	if out:
		_tween.tween_callback(func(): habilites_container.active = true)


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


func _on_select_by_type(type: CombatUtils.Actions):
	current_action = type


func _on_change_by_id(id: int) -> void:
	if not active or id == 0:
		return
	if not id in CombatUtils.Actions.values():
		push_error("S'ha intentat habilitar un CombatUtils.Actions que no existeix (%s)." % id)
		return
	current_action = id as CombatUtils.Actions
