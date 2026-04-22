extends Area3D
class_name Tile

@export var mesh: MeshInstance3D
var _current_entity: Entity
signal entity_changed

var base_color: Color = Color(1.0, 1.0, 1.0):
	get:
		return base_color
	set(value):
		base_color = value
		ChangeColor(base_color)

var _board: Board:
	get:
		if Board.instance == null:
			push_error("Tile: No hi ha cap Board actiu en la escena.")
			return null
		return Board.instance

func _ready() -> void:
	area_entered.connect(_OnAreaEnter)
	area_exited.connect(_OnAreaExit)
	MakeUniqueMaterials()

var current_entity: Entity:
	get:
		return _current_entity

var tile_position: Vector2i:
	get:
		return Board.WorldToTileID(global_position)

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

func MakeUniqueMaterials() -> void:
		for idx in range(mesh.get_surface_override_material_count()):
			var mat := mesh.get_active_material(idx)
			if mat is StandardMaterial3D:
				mesh.set_surface_override_material(
					idx,
					mat.duplicate_deep()
				)

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
	
func MoveToTile(new_position: Vector2i) -> void:
	var world_position := _board.GetWorldPosition(new_position)
	Move(world_position)

func ChangeAlpha(new_alpha: float):
	for mat in materials:
		mat.albedo_color.a = new_alpha
		
func ChangeColor(new_color: Color = base_color):
	for mat in materials:
		mat.albedo_color = new_color
