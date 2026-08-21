class_name ModifiersContainer
extends HBoxContainer

@export var modifier_scene: PackedScene

var _entity: Entity


func on_entity_changed(entity: Entity) -> void:
	if _entity != null and _entity.stats.stats_changed.is_connected(_recalculate_modifiers):
		_entity.stats.stats_changed.disconnect(_recalculate_modifiers)
	_entity = entity
	if _entity == null:
		_delete_modifiers()
		return
	_recalculate_modifiers()
	if not _entity.stats.stats_changed.is_connected(_recalculate_modifiers):
		_entity.stats.stats_changed.connect(_recalculate_modifiers)


func _delete_modifiers() -> void:
	for n in get_children():
		remove_child(n)
		n.queue_free()


func _recalculate_modifiers() -> void:
	_delete_modifiers()
	if modifier_scene == null:
		return

	for mod in _entity.stats.modifiers:
		var container := modifier_scene.instantiate() as ModifierContainer
		container.current_modifier = mod
		add_child(container)
