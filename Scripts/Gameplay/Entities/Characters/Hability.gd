@abstract class_name Hability
extends Node

signal finished(action_used: bool)

@export_enum("By range:0", "By entities in range:1") var generator_type: int

@export var settings: HabilitySettings

var character: Character
var generator: Generator

var active: bool:
	get:
		return _active

var board: Board:
	get:
		return Board.instance

var _active: bool = false


func execute() -> void:
	_active = true
	if settings is HabilityRangeSettings:
		generate_hability_range()
	elif settings is HabilityByObjectsInDistanceSettings:
		generate_by_objects_in_distance()
	_execute()
	var action_used: bool = await finished
	if action_used:
		character.use_action()
	character.trigger_hability_finished()
	generator = null
	_active = false


func generate_hability_range() -> void:
	var st: HabilityRangeSettings = settings as HabilityRangeSettings
	generator = Generator.new(board)
	generator.tile_base_color = st.base_tile_color
	generator.use_astar = false
	generator.distance_type = st.distance_type
	generator.collide_with = st.collide_with
	generator.create_tiles_on_solid = st.create_tiles_on_solid
	generator.show_disabled_tiles = st.show_disabled_tiles
	generator.generate_on_self = st.generate_on_self
	generator.generate_tiles_arround_position(character.board_position, st.total_range)


func generate_by_objects_in_distance() -> void:
	var st: HabilityByObjectsInDistanceSettings = settings as HabilityByObjectsInDistanceSettings
	generator = Generator.new(board)
	generator.tile_base_color = settings.base_tile_color
	generator.create_tiles_on_solid = st.create_tiles_on_solid
	var collisions: Array[Area3D] = _get_collisions_radius(
		character.board_position,
		st.search_radius,
		st.collide_with,
	)
	var ids: Array[Vector2i] = Array(
		collisions.map(
			func(obj: Area3D):
				return Board.world_to_tile_id_rounded(obj.global_position),
		),
		TYPE_VECTOR2I,
		"",
		null,
	)
	generator.generate_tiles_by_ids(character.board_position, ids)


func cancel() -> void:
	finished.emit(false)


@abstract func clicked_tile(tile: Tile)


@abstract func _execute() -> void


func on_tile_hover(_tile: Tile):
	pass


func _get_collisions_radius(
	center: Vector2i,
	radius: float,
	collision_mask: int = -1,
) -> Array[Area3D]:
	var query := PhysicsShapeQueryParameters3D.new()
	query.collision_mask = 4294967295 if collision_mask <= 0 else collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.shape_rid = _create_rid(radius)
	query.transform.origin = character.board.get_world_position(center)
	var space_state := character.get_world_3d().direct_space_state
	var results := space_state.intersect_shape(query)
	var colliders: Array[Area3D] = []
	if results.is_empty():
		return colliders
	for result in results:
		var collider: Area3D = result.collider
		if not collider.monitorable:
			continue
		colliders.append(collider)
	return colliders


func _create_rid(radius: float) -> RID:
	var sphere_rid: RID = PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(sphere_rid, radius)
	return sphere_rid


func on_hability_animation(_animation_name: String):
	pass
