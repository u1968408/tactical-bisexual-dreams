class_name GuiWeaponMarker
extends Control

@export var sprite_ranged: Sprite2D
@export var sprite_tonfa: Sprite2D
@export var sprite_staff: Sprite2D
@export var sprite_bat: Sprite2D

var _all_sprites: Array[Sprite2D]:
	get:
		return [
			sprite_ranged,
			sprite_tonfa,
			sprite_staff,
			sprite_bat,
		]

var _character: Character


func on_character_changed(character: Character) -> void:
	if _character != null and _character.weapons.weapon_changed.is_connected(_change_weapon):
		_character.weapons.weapon_changed.disconnect(_change_weapon)
	_character = character
	if _character == null:
		return
	_change_weapon(_character.weapons.equiped)
	if not _character.weapons.weapon_changed.is_connected(_change_weapon):
		_character.weapons.weapon_changed.connect(_change_weapon)


func _ready() -> void:
	_change_weapon(null)


func _change_weapon(weapon: Weapon):
	_disable_all()
	var weapon_type = weapon.type if weapon != null else Weapon.WTypes.NONE
	var sprite: Sprite2D = _get_sprite(weapon_type)
	if sprite == null:
		visible = false
		return
	visible = true
	sprite.visible = true


func _get_sprite(weapon_type: Weapon.WTypes) -> Sprite2D:
	match weapon_type:
		Weapon.WTypes.RANGED:
			return null
		Weapon.WTypes.SHORT:
			return sprite_tonfa
		Weapon.WTypes.BALANCED:
			return sprite_bat
		Weapon.WTypes.LARGE:
			return sprite_staff
	# Weapon.WTypes.NONE
	return null


func _disable_all():
	for weapon in _all_sprites:
		if weapon == null:
			continue
		weapon.visible = false
