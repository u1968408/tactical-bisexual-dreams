extends PlayerBaseState
class_name UnitSelectedState

@export var free_select_state: FreeSelectPlayerState
@export var selected_tile_color: Color
@export var combat_ui: CombatUI
@export_flags_3d_physics var tile_collision_layer: int
@export_category("Sub State machine")
@export var internal_state_machine: StateMachine
@export_group("Sub States")
@export var move_sub_state: MoveSubState
@export var attack_sub_state: AttackSubState

@onready var _camera: CameraController = get_viewport().get_camera_3d()

var current_character: Character
var can_interact: bool = true

var _current_internal_state: UnitSubState:
	get:
		return internal_state_machine.state

var current_tile: Tile:
	get:
		return current_tile
	set(value):
		if value == current_tile:
			return
		if current_tile:
			current_tile.ChangeColor()
		current_tile = value
		if current_tile:
			current_tile.ChangeColor(selected_tile_color)

func Enter() -> void:
	super()
	combat_ui.active = true
	combat_ui.state = CombatUI.CombatState.Move
	can_interact = true

func Exit():
	super()
#	combat_ui.state = CombatUI.CombatState.None
	internal_state_machine.setCurrentState(null)
	combat_ui.active = false
	current_character = null

func AddListeners() -> void:
	super()
	combat_ui.state_changed.connect(_OnCombatStateChanged)

func RemoveListeners() -> void:
	super()
	combat_ui.state_changed.disconnect(_OnCombatStateChanged)


func on_mouse_move(_screen_position: Vector2, _tile_position: Vector3) -> void:
	if not can_interact:
		return
	_CreateRay(
		_camera.mouse_world_position,
		_camera.mouse_look_position
	)

func on_mouse_click() -> void:
	if not can_interact:
		return
	if current_tile == null:
		return
	_current_internal_state.on_mouse_click()

func on_mouse_secondary_click() -> void:
	if not can_interact:
		return
	ReturnToSelectState()

func _CreateRay(from: Vector3, to: Vector3) -> void:
	var space_state := _camera.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		from,
		to,
		tile_collision_layer
	)
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

func ReturnToSelectState():
	state_machine.setCurrentState(free_select_state)

func _OnCombatStateChanged(state: CombatUI.CombatState):
	match state:
		CombatUI.CombatState.Move:
			internal_state_machine.setCurrentState(move_sub_state)
		CombatUI.CombatState.Attack:
			internal_state_machine.setCurrentState(attack_sub_state)
		CombatUI.CombatState.None:
			internal_state_machine.setCurrentState(null)
