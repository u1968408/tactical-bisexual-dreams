class_name HabilityHandler
extends EntityNode

var habilities: Array[Hability]:
	get:
		var res: Array[Hability]
		for child in get_children():
			if child is Hability:
				res.append(child)
		return res

var active_hability: Hability:
	get:
		for hab in habilities:
			if hab.active:
				return hab
		return null


func _ready() -> void:
	for hab in habilities:
		hab.character = entity as Character


func on_tile_hover(tile: Tile):
	var current_hability := active_hability
	if current_hability == null:
		return
	current_hability.on_tile_hover(tile)


func clicked_tile(tile: Tile):
	var current_hability := active_hability
	if current_hability == null:
		return
	current_hability.clicked_tile(tile)


func cancel_current_hability():
	var hab = active_hability
	if hab != null:
		hab.cancel()


func _on_hability_animation(animation_name: String):
	var hab = active_hability
	if hab != null:
		hab.on_hability_animation(animation_name)
