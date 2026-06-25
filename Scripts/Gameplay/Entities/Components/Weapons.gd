class_name Weapons
extends Node3D

signal weapon_changed(weapon: Weapon)

@export var weapon_sprite: AnimatedSprite3D

@export var equiped: Weapon:
	get:
		return _equiped
	set(value):
		_equiped = value
		weapon_changed.emit(value)
		_set_weapon_sprite()

var _equiped: Weapon

func _ready() -> void:
	weapon_sprite.visible = false
	weapon_sprite.animation_finished.connect(_on_animation_finished)
	_set_weapon_sprite()


func play_attack_animation():
	if equiped != null:
		weapon_sprite.visible = true


func _on_animation_finished() -> void:
	weapon_sprite.visible = false


func _set_weapon_sprite() -> void:
	if equiped == null:
		weapon_sprite.sprite_frames = null
		return
	if weapon_sprite == null:
		return
	weapon_sprite.sprite_frames = equiped.sprite
