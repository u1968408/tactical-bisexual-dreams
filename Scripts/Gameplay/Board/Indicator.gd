extends Tile
class_name Indicator


@export_group("Indicator Colors")
@export var selected_enemy: Color
@export var selected_ally: Color
@export var selected_empty_tile: Color
@export var selected_colliding_terrain: Color



func _ready() -> void:
	ChangeColor(selected_colliding_terrain)
	area_entered.connect(_OnAreaEnter)
	area_exited.connect(_OnAreaExit)

func _process(_delta: float) -> void:
	pass
		
func _OnAreaEnter(area: Area3D) -> void:
	super(area)
	_RecalculateHits(area)
	
func _OnAreaExit(area: Area3D) -> void:
	super(area)
	_RecalculateHits(area)

func _RecalculateHits(area: Area3D) -> void:
	var areas := get_overlapping_areas()
	if Collisions.HasTerreainInList(areas):
		ChangeColor(selected_colliding_terrain)
	elif Collisions.HasEnemiesInList(areas):
		ChangeColor(selected_enemy)
	elif Collisions.HasCharactersInList(areas):
		ChangeColor(selected_ally)
	else:
		ChangeColor(selected_empty_tile)
