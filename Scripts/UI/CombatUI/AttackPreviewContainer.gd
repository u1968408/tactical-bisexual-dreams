class_name AttackPreviewContainer
extends Control

@export var wpn_attacker: TextureRect
@export var wpn_defender: TextureRect
@export var label_probability: Label
@export var label_damage: Label


func configure(attacker: Entity, defender: Entity) -> void:
	var atk_wpn: Weapon = attacker.weapons.equiped
	var def_wpn: Weapon = defender.weapons.equiped

	wpn_attacker.texture = WeaponLibrary.get_weapon_icon(atk_wpn.type) if atk_wpn else null
	wpn_defender.texture = WeaponLibrary.get_weapon_icon(def_wpn.type) if def_wpn else null

	var preview := attacker.attack.get_attack_preview(defender)
	label_probability.text = str(preview.hit_chance)
	label_damage.text = str(preview.damage)
