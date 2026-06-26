class_name UnitSelectedState
extends PlayerBaseState

@export var free_select_state: FreeSelectPlayerState
@export var selected_tile_color: Color
@export var ui_controller: UIController
@export_flags_3d_physics var tile_collision_layer: int
@export_category("Sub State machine")
@export var internal_state_machine: StateMachine
@export_group("Sub States")
@export var move_sub_state: MoveSubState
@export var attack_sub_state: AttackSubState
@export var habilities_sub_state: HabilitiesSubState


var current_character: Character
var can_interact: bool = true

var combat_ui: CombatUI:
	get:
		return ui_controller.combat_ui

var current_tile: Tile:
	get:
		return current_tile
	set(value):
		if value == current_tile:
			return
		if current_tile:
			current_tile.change_color()
		current_tile = value
		if current_tile:
			current_tile.change_color(selected_tile_color)

var _current_internal_state: UnitSubState:
	get:
		return internal_state_machine.state

@onready var _camera: CameraController = get_viewport().get_camera_3d()


func enter() -> void:
	super()
	combat_ui.character_selected(current_character)
	if current_character.has_actions():
		combat_ui.current_action = CombatUtils.Actions.MOVE
	else:
		combat_ui.current_action = CombatUtils.Actions.NONE
	can_interact = true


func exit():
	super()
	internal_state_machine.set_current_state(null)
	combat_ui.character_unselected()
	current_character = null


func add_listeners() -> void:
	super()
	combat_ui.action_changed.connect(_on_combat_state_changed)


func remove_listeners() -> void:
	super()
	combat_ui.action_changed.disconnect(_on_combat_state_changed)


func on_mouse_move(_screen_position: Vector2, _tile_position: Vector3) -> void:
	if not can_interact:
		return
	_create_ray(_camera.mouse_world_position, _camera.mouse_look_position)


func on_mouse_click() -> void:
	if not can_interact:
		return
	if current_tile == null:
		return
	_current_internal_state.on_mouse_click()


func on_mouse_secondary_click() -> void:
	if not can_interact:
		return
	return_to_select_state()


func _create_ray(from: Vector3, to: Vector3) -> void:
	var space_state := _camera.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to, tile_collision_layer)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		current_tile = null
		return
	var collider: Node3D = result.collider
	if collider is not Tile:
		print("Loking from %s to %s and colliding with %s" % [from, to, result.collider])
	else:
		current_tile = collider


func return_to_select_state():
	state_machine.set_current_state(free_select_state)


func _on_combat_state_changed(state: CombatUtils.Actions):
	match state:
		CombatUtils.Actions.MOVE:
			internal_state_machine.set_current_state(move_sub_state)
		CombatUtils.Actions.ATTACK:
			internal_state_machine.set_current_state(attack_sub_state)
		CombatUtils.Actions.HABILITIES:
			internal_state_machine.set_current_state(habilities_sub_state)
		CombatUtils.Actions.NONE:
			internal_state_machine.set_current_state(null)
