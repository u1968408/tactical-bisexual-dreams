extends RefCounted
class_name Generator

var _board: Board
var _center: Vector2i
var _tile_matrix: Dictionary[int, Dictionary]

var _tile_scn: PackedScene = preload("uid://c5kr64xyc0spt")
var _tile_base_color: Color = Color(0.34901962, 0.7411765, 0.8980392, 0.4862745)
var _tile_character_color: Color = Color(0.57254905, 0.25882354, 0.93333334, 1)

var tiles: Array[Tile] = []

func _init(board: Board) -> void:
	_board = board
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_tile_matrix = {}
		for tile in tiles:
#			if not is_instance_valid(tile) or not tile.is_inside_tree() or tile.is_queued_for_deletion():
#				continue
			tile.queue_free()
		tiles = []
	
func GenerateTilesArroundPosition(center: Vector2i, radius: int) -> void:
	print("Creating movement at center %s" % center)
	_center = center
	for pos_x: int in range(center.x -radius, center.x + radius + 1):
		_tile_matrix[pos_x] = {}
		for pos_y: int in range(center.y -radius, center.y +radius +1):
			var new_pos := Vector2i(pos_x, pos_y)
			if Tile.ManhathanDistance(new_pos, center) > radius:
				_tile_matrix[pos_x][pos_y] = null
				continue
			var tile: Tile = _tile_scn.instantiate()
			_tile_matrix[pos_x][pos_y] = tile
			tile.base_color = _tile_base_color
			tile.MoveToTile(new_pos)
			_board.add_child(tile)
			tiles.append(tile)
	_recalculate_tiles()

func _recalculate_tiles():
	await _board.get_tree().physics_frame
	await _board.get_tree().physics_frame
	for tile in tiles:
		if tile.touching_character:
			tile.base_color = _tile_character_color
		elif tile.touching_terrain:
			tiles.remove_at(tiles.find(tile))
			_tile_matrix[tile.tile_position.x][tile.tile_position.y] = null
			tile.queue_free()
	for x in _tile_matrix.keys():
		for y in _tile_matrix[x].keys():
			var value: Variant = _tile_matrix[x][y]
			print("Value[%s, %s] %s" % [x,y, value])
