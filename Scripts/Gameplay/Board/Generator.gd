extends RefCounted
class_name Generator

var _board: Board
var _center: Vector2i

var _tile_scn: PackedScene = preload("uid://c5kr64xyc0spt")
var tile_base_color: Color = Color(0.34901962, 0.7411765, 0.8980392, 0.4862745)

var _movement_paths: Array[MovementPath] = []

class MovementPath extends RefCounted:
	var tile: Tile
	var path: PackedVector2Array

	func _init(origin: Tile, found_path: PackedVector2Array) -> void:
		self.tile = origin
		self.path = found_path
	
	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			if not is_instance_valid(tile) or not tile.is_inside_tree() or tile.is_queued_for_deletion():
				return
			tile.queue_free()
	
	

func _init(board: Board) -> void:
	_board = board
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_movement_paths = []

func GetPathForTile(tile: Tile) -> PackedVector2Array:
	for mov_path in _movement_paths:
		if mov_path.tile == tile:
			return mov_path.path
	return PackedVector2Array()

func GenerateTilesArroundPosition(center: Vector2i, radius: int) -> void:
	print("Creating movement at center %s" % center)
	_center = center
	var min_tile := Vector2i(center.x -radius, center.y -radius)
	var max_tile := Vector2i(center.x +radius, center.y +radius)
	_board.SetSolid(_center, false)
	for tile_candidate: Vector2i in Vector2iIterator.new(min_tile, max_tile):
		var path := _board.FindPath(center, tile_candidate, radius)
		if path.is_empty():
			continue
		var tile: Tile = _tile_scn.instantiate()
		tile.base_color = tile_base_color
		tile.MoveToTile(tile_candidate)
		_board.add_child(tile)
		var mov_p := MovementPath.new(tile, path)
		_movement_paths.append(mov_p)
	_board.SetSolid(_center, true)
