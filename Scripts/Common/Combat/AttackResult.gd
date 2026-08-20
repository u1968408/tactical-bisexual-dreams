class_name AttackResult
extends RefCounted

var hit: bool
var damage: int
var damaged_entity: Entity


func _init(hitted: bool, damage_done: int, receiver: Entity) -> void:
	self.hit = hitted
	self.damage = damage_done
	self.damaged_entity = receiver
