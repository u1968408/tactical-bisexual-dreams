## Gestiona la graella lògica i la representació espacial del tauler de joc.
##
## Aquesta classe s'encarrega de la inicialització del sistema AStarGrid2D, 
## la detecció de col·lisions per determinar cel·les sòlides i la conversió 
## entre coordenades del món 3D i coordenades de la graella.
extends Node3D
class_name Board

const TILE_SIZE: Vector2 = Vector2(1, 1)
const TILE_HEIGHT: float = 0.1

static var instance: Board

@export_flags_3d_physics var terrain_collision_layer: int
@export_flags_3d_physics var entities_collision_layer: int


var _min := Vector2i(-10, -10)
var _max := Vector2i(10, 10)
var _astar := AStarGrid2D.new()
var _tile_shape_rid: RID = _CreateTileRID()
var _tile_extents := Vector3(
		(TILE_SIZE.x * 0.9), 
		TILE_HEIGHT,
		(TILE_SIZE.y * 0.9)
)
var _debug_mode: bool = false

## La coordenada mínima de la regió del tauler.
var min_tile: Vector2i:
	get:
		return _min

## La coordenada màxima de la regió del tauler.
var max_tile: Vector2i:
	get:
		return _max

func _ready() -> void:
	instance = self
	_initializeTerrain()
	_setTerrainTiles()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_toggle"):
		_debug_mode = !_debug_mode
	if _debug_mode:
		for current_id: Vector2i in _GetTileIds():
			_DebugDrawTile(current_id)

func _exit_tree() -> void:
	_DeleteTileRID()

## Converteix una posició del món 3D a un identificador de cel·la basat en el terra de la divisió.
## [br][br]Aquesta és una alternativa més directa a [method PositionOnBoard] per a càlculs de graella estàndard.
static func WorldToTileID(world_pos: Vector3) -> Vector2i:
	var local_x := world_pos.x
	var local_z := world_pos.z
	return Vector2i(floor(local_x / TILE_SIZE.x), floor(local_z / TILE_SIZE.y))

static func ManhathanDistance(pos1: Vector2i, pos2: Vector2i) -> int:
	return absi(pos1.x - pos2.x) + absi(pos1.y - pos2.y)

func SetSolid(tile_id: Vector2i, solid: bool):
	_astar.set_point_solid(tile_id, solid)

func IsTileWalkable(tile_id: Vector2i) -> bool:
	return _astar.is_in_boundsv(tile_id) and not _astar.is_point_solid(tile_id)

func FindPath(origin: Vector2i, destination: Vector2i, max_distance: int = -1) -> PackedVector2Array:
	if not _astar.is_in_boundsv(origin) or not IsTileWalkable(destination):
		print("Not walkable path (origin_in_bounds=%s, is_destination_walkable=%s)" % [_astar.is_in_boundsv(origin), IsTileWalkable(destination)])
		return PackedVector2Array()
	var _path := _astar.get_point_path(origin, destination)
	if _path.size() < 2:
		return PackedVector2Array()
	if max_distance > 0 and len(_path) - 1 > max_distance:
		return PackedVector2Array()
	return _path

## Obté la posició en el món 3D d'una cel·la específica de la graella AStar.
## [br][br][b]Paràmetres:[/b]
## [br]- [param id]: Les coordenades de la cel·la.
## [br]- [param corner]: Si és cert, retorna la posició de la cantonada superior esquerra en lloc del centre.
func GetWorldPosition(id: Vector2i, use_corner: bool = false) -> Vector3:
	var pos := _astar.get_point_position(id)
	if use_corner:
		pos.x -= TILE_SIZE.x / 2
		pos.y -= TILE_SIZE.y / 2
	return Vector3(pos.x, 0, pos.y)

## Troba la posició espacial exacte de la cel·la més propera a un punt 3D.
## [br][b]Paràmetres:[/b]
## [br]- [param other_position]: La posició d'origen (ex: posició del ratolí).
## [br]- [param use_corner]: Si és cert, ajusta el punt a la cantonada superior esquerra.
## [br][b]Retorna:[/b] Un [Vector3] amb la posició alineada o [code]null[/code] si està fora del tauler.
func PositionMatchedToTile(other_position: Vector3, use_corner: bool = false) -> Variant:
	var tile_id := WorldToTileID(other_position)
	if not _astar.is_in_bounds(tile_id.x, tile_id.y):
		return null
	var recalculated_pos := GetWorldPosition(tile_id, use_corner)
	return recalculated_pos

func _initializeTerrain() -> void:
	var width := max_tile.x - min_tile.x + 1
	var height := max_tile.y - min_tile.y + 1
	_astar.region = Rect2i(
		min_tile.x,
		min_tile.y,
		width,
		height,
	)
	_astar.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	_astar.cell_size = TILE_SIZE
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()

func _GetTileIds() -> Vector2iIterator:
	return Vector2iIterator.new(min_tile, max_tile)
	
func _setTerrainTiles() -> void:
	for current_id: Vector2i in _GetTileIds():
		if _GetCollisionsInArea(current_id).is_empty():
			continue
		_astar.set_point_solid(current_id, true)

func _DebugDrawTile(tile_id: Vector2i) -> void:
	var pos := GetWorldPosition(tile_id, true)
	DebugDraw3D.draw_box(
		pos,
		Quaternion.IDENTITY,
		_tile_extents,
		Color(0, 0, 0, 0),
		false,
		0
	)
	
func _GetCollisionsInArea(query_id: Vector2i, include_entities: bool = true) -> Array[Node3D]:
	var query := PhysicsShapeQueryParameters3D.new()
	query.collision_mask = terrain_collision_layer
	if include_entities:
		query.collision_mask += entities_collision_layer
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.shape_rid = _tile_shape_rid
	query.transform.origin = GetWorldPosition(query_id)
	var space_state := get_world_3d().direct_space_state
	var results := space_state.intersect_shape(query)
	var colliders: Array[Node3D] = []
	if results.is_empty():
		return colliders
	for result in results:
		var collider: Node3D = result.collider
		print("Casting area on %s (%s) and colliding with %s" % [query_id,query.transform.origin, collider.name])
		colliders.append(collider)
	return colliders

func _CreateTileRID() -> RID:
	var box_rid :RID = PhysicsServer3D.box_shape_create()
	var half_extents := Vector3(
		(TILE_SIZE.x * 0.9) / 2.0, 
		TILE_HEIGHT / 2.0,
		(TILE_SIZE.y * 0.9) / 2.0
	)
	PhysicsServer3D.shape_set_data(box_rid, half_extents)
	return box_rid

func _DeleteTileRID() -> void:
	PhysicsServer3D.free_rid(_tile_shape_rid)