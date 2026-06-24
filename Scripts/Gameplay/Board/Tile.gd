class_name Tile
extends Area3D

signal entity_changed

@export var mesh: MeshInstance3D

var base_color: Color = Color(1.0, 1.0, 1.0):
	get:
		return base_color
	set(value):
		base_color = value
		change_color(base_color)

var current_entity: Entity:
	get:
		return _current_entity

var tile_position: Vector2i:
	get:
		return Board.world_to_tile_id(global_position)

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

var _current_entity: Entity

var _board: Board:
	get:
		if Board.instance == null:
			push_error("Tile: No hi ha cap Board actiu en la escena.")
			return null
		return Board.instance


func _ready() -> void:
	area_entered.connect(_on_area_enter)
	area_exited.connect(_on_area_exit)
	_make_unique_materials()


func _make_unique_materials() -> void:
	for idx in range(mesh.get_surface_override_material_count()):
		var mat := mesh.get_active_material(idx)
		if mat is StandardMaterial3D:
			mesh.set_surface_override_material(idx, mat.duplicate_deep())


func _on_area_enter(area: Area3D) -> void:
	if area is Entity:
		_current_entity = area
		entity_changed.emit(area)


func _on_area_exit(area: Area3D) -> void:
	if area is Entity and area == _current_entity:
		_current_entity = null
		entity_changed.emit(area)


func move(new_position: Vector3) -> void:
	if new_position == null or position == new_position:
		return
	position = new_position


func move_to_tile(new_position: Vector2i) -> void:
	var world_position := _board.get_world_position(new_position)
	move(world_position)


func change_alpha(new_alpha: float):
	for mat in materials:
		mat.albedo_color.a = new_alpha


func change_color(new_color: Color = base_color):
	for mat in materials:
		mat.albedo_color = new_color
