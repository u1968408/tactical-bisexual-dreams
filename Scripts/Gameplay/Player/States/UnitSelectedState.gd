extends PlayerBaseState
class_name UnitSelectedState

@export var free_select_state: FreeSelectPlayerState
@export var selected_tile_color: Color
@export_flags_3d_physics var tile_collision_layer: int

@onready var _camera: CameraController = get_viewport().get_camera_3d()

var current_character: Character
var generator: Generator

var _entity_moving: bool = false

var _current_selected_tile: Tile:
	get:
		return _current_selected_tile
	set(value):
		if value == _current_selected_tile:
			return
		if _current_selected_tile:
			_current_selected_tile.ChangeColor()
		_current_selected_tile = value
		if _current_selected_tile:
			_current_selected_tile.ChangeColor(selected_tile_color)
		

func Enter() -> void:
	super()
	generator = Generator.new(board)
	if current_character == null:
		push_error("S'ha entrat al estat de unitat seleccionada sense seleccionar unitat.")
		state_machine.setCurrentState(free_select_state)
		return
	generator.GenerateTilesArroundPosition(
		current_character.board_position,
		current_character.stats.movement
	)
		
func _create_ray(from: Vector3, to: Vector3) -> void:
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
		_current_selected_tile = null
		return
	var collider: Node3D = result.collider
	if collider is not Tile:
		print("Loking from %s to %s and colliding with %s" % [from, to, result.collider])
	else:
		_current_selected_tile = collider

func Exit():
	super()
	generator = null
	current_character = null

func AddListeners() -> void:
	super()
	current_character.movement.movement_ended.connect(
		_OnMovementEnded
	)

func RemoveListeners() -> void:
	super()
	if current_character == null: return
	current_character.movement.movement_ended.disconnect(
		_OnMovementEnded
	)

func on_mouse_move(_screen_position: Vector2, _tile_position: Vector3) -> void:
	if _entity_moving:
		return
	_create_ray(
		_camera.mouse_world_position,
		_camera.mouse_look_position
	)

func on_mouse_click() -> void:
	if _entity_moving:
		return
	if _current_selected_tile == null:
		return 
	if _current_selected_tile.current_entity != null:
		push_error("Encara no he programat aixo")
		return
	
	var path := generator.GetPathForTile(_current_selected_tile)
	current_character.Move(path)
	generator = null
	
func on_mouse_secondary_click() -> void:
	if _entity_moving:
		return
	state_machine.setCurrentState(free_select_state)

func _OnMovementEnded():
	state_machine.setCurrentState(free_select_state)
