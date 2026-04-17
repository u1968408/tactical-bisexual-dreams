extends RefCounted
class_name Generator

var _board: Board

var tile_scn: PackedScene = preload("uid://c5kr64xyc0spt")
var tile_base_color: Color = Color(0.34901962, 0.7411765, 0.8980392, 0.4862745)

func _init(board: Board) -> void:
	_board = board
	
func GenerateTilesArroundPosition(center: Vector2i, radius: int) -> void:
	print("Creating movement at center %s" % center)
	for pos_x in range(center.x -radius, center.x + radius + 1):
		for pos_y in range(center.y -radius, center.y +radius +1):
			var new_pos := Vector2i(pos_x, pos_y)
			if Tile.ManhathanDistance(new_pos, center) > radius:
				continue
			var tile: Tile = tile_scn.instantiate()
			tile.ChangeColor(tile_base_color)
			tile.MoveToTile(new_pos)
			_board.add_child(tile)