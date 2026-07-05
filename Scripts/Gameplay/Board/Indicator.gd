class_name Indicator
extends Tile

## Velocitat de suavitzat (més alt = més ràpid).
@export var follow_speed: float = 20.0

@export_group("Indicator Colors")
@export var selected_enemy: Color
@export var selected_ally: Color
@export var selected_empty_tile: Color
@export var selected_colliding_terrain: Color

var target_tile_id: Vector2i:
	get:
		return Board.world_to_tile_id_floor(_target_position)

var _target_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	super()
	change_color(selected_colliding_terrain)


func _process(delta: float) -> void:
	if global_position.distance_squared_to(_target_position) > 0.00001:
		global_position = global_position.lerp(_target_position, follow_speed * delta)


func _on_area_enter(area: Area3D) -> void:
	super(area)
	_recalculate_hits(area)


func _on_area_exit(area: Area3D) -> void:
	super(area)
	_recalculate_hits(area)


func _recalculate_hits(_area: Area3D) -> void:
	var areas := get_overlapping_areas()
	if Collisions.has_terrain_in_list(areas):
		change_color(selected_colliding_terrain)
	elif Collisions.has_enemies_in_list(areas):
		change_color(selected_enemy)
	elif Collisions.has_characters_in_list(areas):
		change_color(selected_ally)
	else:
		change_color(selected_empty_tile)


func move(new_position: Vector3) -> void:
	if new_position == null:
		return
	_target_position = new_position
