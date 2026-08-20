class_name AttackPreview
extends RefCounted

var hit_chance: int
var damage: int


func _init(chance: int, dmg: int) -> void:
	self.hit_chance = chance
	self.damage = dmg
