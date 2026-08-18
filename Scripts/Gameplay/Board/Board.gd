## Gestiona la graella lògica i la representació espacial del tauler de joc.
##
## Aquesta classe s'encarrega de la inicialització del sistema AStarGrid2D,
## la detecció de col·lisions per determinar cel·les sòlides i la conversió
## entre coordenades del món 3D i coordenades de la graella.
class_name Board
extends Node3D

const TILE_SIZE: Vector2 = Vector2(1, 1)
const TILE_HEIGHT: float = 0.1

static var instance: Board

@export_flags_3d_physics var terrain_collision_layer: int
@export_flags_3d_physics var entities_collision_layer: int

@export var _min := Vector2i(-10, -10)
@export var _max := Vector2i(10, 10)

## La coordenada mínima de la regió del tauler.
var min_tile: Vector2i:
	get:
		return _min

## La coordenada màxima de la regió del tauler.
var max_tile: Vector2i:
	get:
		return _max

var region: Rect2:
	get:
		var width := max_tile.x - min_tile.x + 1
		var height := max_tile.y - min_tile.y + 1
		return Rect2(
			min_tile.x,
			min_tile.y,
			width,
			height,
		)

var _astar := AStarGrid2D.new()
var _tile_shape_rid: RID = _create_tile_rid()
var _tile_extents := Vector3(TILE_SIZE.x * 0.9, TILE_HEIGHT, TILE_SIZE.y * 0.9)
var _debug_mode: bool = false


func _init() -> void:
	instance = self


func _ready() -> void:
	_initialize_terrain()
	_set_terrain_tiles()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_toggle"):
		_debug_mode = !_debug_mode
	if _debug_mode:
		for current_id: Vector2i in _get_tile_ids():
			_debug_draw_tile(current_id)


func _exit_tree() -> void:
	_delete_tile_rid()


## Converteix una posició del món 3D a un identificador de cel·la basat en el terra de la divisió.
static func world_to_tile_id_floor(world_pos: Vector3) -> Vector2i:
	var local_x := world_pos.x
	var local_z := world_pos.z
	return Vector2i(floori(local_x / TILE_SIZE.x), floori(local_z / TILE_SIZE.y))


static func world_to_tile_id_rounded(world_pos: Vector3) -> Vector2i:
	var local_x := world_pos.x
	var local_z := world_pos.z
	return Vector2i(roundi(local_x / TILE_SIZE.x), roundi(local_z / TILE_SIZE.y))


static func manhathan_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	return absi(pos1.x - pos2.x) + absi(pos1.y - pos2.y)


static func chebyshev_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	return maxi(abs(pos1.x - pos2.x), abs(pos1.y - pos2.y))


func set_solid(tile_id: Vector2i, solid: bool) -> void:
	_astar.set_point_solid(tile_id, solid)


func is_solid(tile_id: Vector2i) -> bool:
	return _astar.is_point_solid(tile_id)


func is_outside(tile_id: Vector2i) -> bool:
	return not _astar.is_in_boundsv(tile_id)


func is_position_outside(pos: Vector3):
	var pos2: Vector2 = Vector2(pos.x, pos.z)
	return not region.has_point(pos2)


func is_tile_walkable(tile_id: Vector2i) -> bool:
	return _astar.is_in_boundsv(tile_id) and not _astar.is_point_solid(tile_id)


func find_path(
	origin: Vector2i, destination: Vector2i, max_distance: int = -1
) -> PackedVector2Array:
	if not _astar.is_in_boundsv(origin) or not is_tile_walkable(destination):
		return PackedVector2Array()
	var path := _astar.get_point_path(origin, destination)
	if path.size() < 2:
		return PackedVector2Array()
	if max_distance > 0 and len(path) - 1 > max_distance:
		return PackedVector2Array()
	return path


## Obté la posició en el món 3D d'una cel·la específica de la graella AStar.
## [br][br][b]Paràmetres:[/b]
## [br]- [param id]: Les coordenades de la cel·la.
## [br]- [param corner]: Si és cert, retorna la posició de la cantonada superior
## esquerra en lloc del centre.
func get_world_position(id: Vector2i, use_corner: bool = false) -> Vector3:
	var pos := _astar.get_point_position(id)
	if use_corner:
		pos.x -= TILE_SIZE.x / 2
		pos.y -= TILE_SIZE.y / 2
	return Vector3(pos.x, 0, pos.y)


## Troba la posició espacial exacte de la cel·la més propera a un punt 3D.
## [br][b]Paràmetres:[/b]
## [br]- [param other_position]: La posició d'origen (ex: posició del ratolí).
## [br]- [param use_corner]: Si és cert, ajusta el punt a la cantonada superior esquerra.
## [br][b]Retorna:[/b] Un [Vector3] amb la posició alineada o [code]null[/code] si està
## fora del tauler.
func position_matched_to_tile(other_position: Vector3, use_corner: bool = false) -> Variant:
	var tile_id := world_to_tile_id_floor(other_position)
	if not _astar.is_in_bounds(tile_id.x, tile_id.y):
		return null
	var recalculated_pos := get_world_position(tile_id, use_corner)
	return recalculated_pos


func _initialize_terrain() -> void:
	_astar.region = Rect2i(region)
	_astar.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	_astar.cell_size = TILE_SIZE
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()


func _get_tile_ids() -> Vector2iIterator:
	return Vector2iIterator.new(min_tile, max_tile)


func _set_terrain_tiles() -> void:
	for current_id: Vector2i in _get_tile_ids():
		var collision_mask: int = terrain_collision_layer + entities_collision_layer
		var collisions = get_collisions_in_area(current_id, collision_mask)
		if collisions.is_empty():
			continue
		_astar.set_point_solid(current_id, true)


func _debug_draw_tile(tile_id: Vector2i) -> void:
	var pos := get_world_position(tile_id, true)
	DebugDraw3D.draw_box(pos, Quaternion.IDENTITY, _tile_extents, Color(1, 0, 0, 0), false, 0)


func get_collisions_in_area(query_id: Vector2i, collision_mask: int) -> Array[Node3D]:
	var query := PhysicsShapeQueryParameters3D.new()
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.shape_rid = _tile_shape_rid
	query.transform.origin = get_world_position(query_id)
	var space_state := get_world_3d().direct_space_state
	var results := space_state.intersect_shape(query)
	var colliders: Array[Node3D] = []
	if results.is_empty():
		return colliders
	for result in results:
		var collider: Node3D = result.collider
		colliders.append(collider)
	return colliders


func _create_tile_rid() -> RID:
	var box_rid: RID = PhysicsServer3D.box_shape_create()
	var half_extents := Vector3(
		(TILE_SIZE.x * 0.9) / 2.0, TILE_HEIGHT / 2.0, (TILE_SIZE.y * 0.9) / 2.0
	)
	PhysicsServer3D.shape_set_data(box_rid, half_extents)
	return box_rid


func _delete_tile_rid() -> void:
	PhysicsServer3D.free_rid(_tile_shape_rid)
