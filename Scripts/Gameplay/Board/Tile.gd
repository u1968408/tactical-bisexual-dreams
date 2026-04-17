extends Area3D
class_name Tile

@export var mesh: MeshInstance3D

var _current_entity: Entity
signal entity_changed

static func ManhathanDistance(pos1: Vector2i, pos2: Vector2i) -> int:
	return absi(pos1.x - pos2.x) + absi(pos1.y - pos2.y)
	
var tile_position: Vector2i:
	get:
		return Board.PositionOnBoard(global_position)

var touching_terrain: bool:
	get:
		return Collisions.HasTerreainInList(get_overlapping_areas())

var touching_enemies: bool:
	get:
		return Collisions.HasEnemiesInList(get_overlapping_areas())

var touching_character: bool:
	get:
		return Collisions.HasCharactersInList(get_overlapping_areas())

var materials: Array[StandardMaterial3D]:
	get:
		var result: Array[StandardMaterial3D] = []
		for idx in range(mesh.get_surface_override_material_count()):
			var mat := mesh.get_active_material(idx)
			if mat is StandardMaterial3D:
				result.append(mat)
		return result	
		
func _OnAreaEnter(area: Area3D) -> void:
	if area is Entity:
		_current_entity = area
		entity_changed.emit(area)

func _OnAreaExit(area: Area3D) -> void:
	if area is Entity and area == _current_entity:
		_current_entity = null
		entity_changed.emit(area)

func Move(new_position: Vector3) -> void:
	if new_position == null or position == new_position:
		return
	position = new_position
	
func MoveToTile(new_position: Vector2) -> void:
	Move(Vector3(new_position.x, 0, new_position.y))

func ChangeAlpha(new_alpha: float):
	for mat in materials:
		mat.albedo_color.a = new_alpha
		
func ChangeColor(new_color: Color):
	for mat in materials:
		mat.albedo_color = new_color