class_name AttackResult
extends RefCounted

var hit: bool
var damage: int


func _init(hitted: bool, damage_done: int) -> void:
	self.hit = hitted
	self.damage = damage_done
