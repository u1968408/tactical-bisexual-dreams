extends Node3D
class_name Weapons

@export var weapon_sprite: AnimatedSprite3D

@export var equiped: Weapon:
	get:
		return equiped
	set(value):
		equiped = value
		_SetWeaponSprite()

func _ready() -> void:
	weapon_sprite.visible = false
	weapon_sprite.animation_finished.connect(_OnAnimationFinished)
	_SetWeaponSprite()

func PlayAttackAnimation():
	if equiped != null:
		weapon_sprite.visible = true

func _OnAnimationFinished() -> void:
	weapon_sprite.visible = false

func _SetWeaponSprite() -> void:
	if equiped == null:
		weapon_sprite.sprite_frames = null
		return
	if weapon_sprite == null:
		return
	weapon_sprite.sprite_frames = equiped.sprite
