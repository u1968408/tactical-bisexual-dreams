extends Sprite2D

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


func _ready() -> void:
	change_weapon(Weapon.WTypes.NONE)


func change_weapon(weapon_type: Weapon.WTypes):
	_disable_all()
	var sprite: Sprite2D = _get_sprite(weapon_type)
	if sprite == null:
		visible = false
		return
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
