extends Node
class_name EntityNode

@onready var entity: Entity = __get_entity()

func __get_entity(parent: Node = get_parent()) -> Entity:
	if parent == null:
		push_error("No s'ha trobat una Entity entre els pares de %s." % self)
		return null
	if parent is Entity:
		return parent
	return __get_entity(parent.get_parent())