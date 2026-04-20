extends Tile
class_name Indicator

## Velocitat de suavitzat (més alt = més ràpid).
@export var follow_speed: float = 20.0

@export_group("Indicator Colors")
@export var selected_enemy: Color
@export var selected_ally: Color
@export var selected_empty_tile: Color
@export var selected_colliding_terrain: Color

var _target_position: Vector3 = Vector3.ZERO

var target_tile_id: Vector2i:
	get:
		return Board.WorldToTileID(_target_position)


func _ready() -> void:
	super()
	ChangeColor(selected_colliding_terrain)

func _process(delta: float) -> void:
	if global_position.distance_squared_to(_target_position) > 0.00001:
		global_position = global_position.lerp(_target_position, follow_speed * delta)
		
func _OnAreaEnter(area: Area3D) -> void:
	super(area)
	_RecalculateHits(area)
	
func _OnAreaExit(area: Area3D) -> void:
	super(area)
	_RecalculateHits(area)

func _RecalculateHits(_area: Area3D) -> void:
	var areas := get_overlapping_areas()
	if Collisions.HasTerreainInList(areas):
		ChangeColor(selected_colliding_terrain)
	elif Collisions.HasEnemiesInList(areas):
		ChangeColor(selected_enemy)
	elif Collisions.HasCharactersInList(areas):
		ChangeColor(selected_ally)
	else:
		ChangeColor(selected_empty_tile)

func Move(new_position: Vector3) -> void:
	if new_position == null:
		return
	_target_position = new_position
