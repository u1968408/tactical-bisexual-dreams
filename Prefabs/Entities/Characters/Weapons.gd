extends Node3D
class_name Weapons

@export var weapon_sprite: AnimatedSprite3D

var equiped: Weapon:
	get:
		return equiped
	set(value):
		equiped = value
		_SetWeaponSprite()

func _ready() -> void:
	weapon_sprite.visible = false
	_SetWeaponSprite()

func _SetWeaponSprite() -> void:
	if equiped == null:
		weapon_sprite.sprite_frames = null
		return
	weapon_sprite.sprite_frames = equiped.sprite
