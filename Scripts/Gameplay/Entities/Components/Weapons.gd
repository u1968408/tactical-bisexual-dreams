class_name Weapons
extends Node3D

signal weapon_changed(weapon: Weapon)

@export var equiped: Weapon:
	get:
		return _equiped
	set(value):
		if _equiped != null and _entity != null:
			for mod in _equiped.modifiers:
				_entity.stats.delete_modifier(mod)
		_equiped = value
		if _equiped != null and _entity != null:
			for mod in _equiped.modifiers:
				_entity.stats.add_modifier(mod)
		weapon_changed.emit(value)

var _equiped: Weapon

@onready var _entity: Entity = _get_entity()


func _ready() -> void:
	equiped = _equiped


func _get_entity(parent: Node = get_parent()) -> Entity:
	if parent == null:
		push_error("No s'ha trobat una Entity entre els pares de %s." % self)
		return null
	if parent is Entity:
		return parent
	return _get_entity(parent.get_parent())
