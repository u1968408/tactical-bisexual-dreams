extends Hability

@export var modifier: Modifier
@export var hability_color: Color

var torus_scene: PackedScene = preload("uid://djq8dm66qe4dj")


func clicked_tile(tile: Tile):
	if tile.current_entity == null:
		finished.emit(false)
		return
	var entity: Entity = tile.current_entity
	if entity.stats.has_modifier(modifier):
		print("%s already has modifier." % entity.name)
		finished.emit(false)
		return

	var torus: Torus = torus_scene.instantiate()
	entity.add_child(torus)
	torus.color = hability_color
	torus.play_animation()

	await torus.finished

	torus.queue_free()
	entity.stats.add_modifier(modifier)
	finished.emit(true)


func _execute() -> void:
	pass
