extends Hability

@export var modifier: Modifier


func clicked_tile(tile: Tile):
	if tile.current_entity == null:
		finished.emit(false)
		return
	var entity: Entity = tile.current_entity
	if entity.stats.has_modifier(modifier):
		print("%s already has modifier." % entity.name)
		finished.emit(false)
		return
	entity.stats.add_modifier(modifier)
	finished.emit(true)


func _execute() -> void:
	pass
