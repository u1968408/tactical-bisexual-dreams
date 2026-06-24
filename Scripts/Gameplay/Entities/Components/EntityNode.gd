class_name EntityNode
extends Node

@onready var entity: Entity = _get_entity()

func _get_entity(parent: Node = get_parent()) -> Entity:
	if parent == null:
		push_error("No s'ha trobat una Entity entre els pares de %s." % self)
		return null
	if parent is Entity:
		return parent
	return _get_entity(parent.get_parent())