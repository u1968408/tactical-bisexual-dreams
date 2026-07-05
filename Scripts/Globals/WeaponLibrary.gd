extends Node

const WEAPON_DIR := "res://Resources/Combat/Weapons/"

var all_weapons: Array[Weapon]

## Diccionari de { `Weapon.WTypes`: { `WeaponMaterials.MaterialTypes`: `Weapon` }}
var _weapon_dict: Dictionary[int, Dictionary] = {}


func _ready() -> void:
	_load_weapons()


func _load_weapons():
	all_weapons = []
	for path in ResourceLoader.list_directory(WEAPON_DIR):
		var weapon: Weapon = ResourceLoader.load(WEAPON_DIR + path, "Weapon")
		if weapon == null:
			continue
		all_weapons.append(weapon)
		if (
			weapon.type == Weapon.WTypes.NONE
			or weapon.material == WeaponMaterials.MaterialTypes.NONE
		):
			continue
		if not _weapon_dict.has(weapon.type):
			_weapon_dict.set(weapon.type, {})
		_weapon_dict[weapon.type][weapon.material] = weapon


func get_weapon(type: Weapon.WTypes, material: WeaponMaterials.MaterialTypes):
	return _weapon_dict.get(type, {}).get(material, null)
