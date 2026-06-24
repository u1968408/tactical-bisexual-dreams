class_name Generator
extends RefCounted

var tile_base_color: Color = Color(0.34901962, 0.7411765, 0.8980392, 1)
var use_astar: bool = true

var _board: Board
var _center: Vector2i
var _radius: int
var _tile_scn: PackedScene = preload("uid://c5kr64xyc0spt")
var _movement_paths: Array[MovementPath] = []


class MovementPath:
	extends RefCounted
	var tile: Tile
	var path: PackedVector2Array

	func _init(origin: Tile, found_path: PackedVector2Array) -> void:
		self.tile = origin
		self.path = found_path

	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			if (
				not is_instance_valid(tile)
				or not tile.is_inside_tree()
				or tile.is_queued_for_deletion()
			):
				return
			tile.queue_free()


func _init(board: Board) -> void:
	_board = board


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_movement_paths = []


func get_path_for_tile(tile: Tile) -> PackedVector2Array:
	for mov_path in _movement_paths:
		if mov_path.tile == tile:
			return mov_path.path
	return PackedVector2Array()


func generate_tiles_arround_position(center: Vector2i, radius: int) -> void:
	print("Creating movement at center %s" % center)
	_center = center
	_radius = radius
	var min_tile := Vector2i(center.x - radius, center.y - radius)
	var max_tile := Vector2i(center.x + radius, center.y + radius)
	_board.set_solid(_center, false)
	for tile_candidate: Vector2i in Vector2iIterator.new(min_tile, max_tile):
		var mov_p: MovementPath = null
		if tile_candidate == center:
			continue
		if use_astar:
			mov_p = _movement_from_astar(tile_candidate)
		else:
			mov_p = _movement_without_astar(tile_candidate)
		if mov_p == null:
			continue
		_movement_paths.append(mov_p)
	_board.set_solid(_center, true)


func _movement_without_astar(tile_candidate: Vector2i) -> MovementPath:
	var dist: int = Board.manhathan_distance(tile_candidate, _center)
	if dist > _radius:
		return null
	var tile := _create_tile(tile_candidate)
	var path := PackedVector2Array(
		[
			_center,
			tile_candidate,
		]
	)
	var mov_p := MovementPath.new(tile, path)
	return mov_p


func _movement_from_astar(tile_candidate: Vector2i) -> MovementPath:
	var path := _board.find_path(_center, tile_candidate, _radius)
	if path.is_empty():
		return null
	var tile := _create_tile(tile_candidate)
	var mov_p := MovementPath.new(tile, path)
	return mov_p


func _create_tile(tile_candidate: Vector2i) -> Tile:
	var tile: Tile = _tile_scn.instantiate()
	tile.base_color = tile_base_color
	tile.move_to_tile(tile_candidate)
	_board.add_child(tile)
	return tile
