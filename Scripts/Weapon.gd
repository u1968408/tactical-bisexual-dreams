class_name Weapon
extends Resource

enum WTypes {
	NONE = 0,
	RANGED = 1,
	SHORT = 2,
	BALANCED = 3,
	LARGE = 4,
}

@export var name: String
@export var material: WeaponMaterials.MaterialTypes
@export var attack_range: int = 1
@export var damage: int = 15
@export var type: WTypes = WTypes.BALANCED
@export var modifiers: Array[Modifier] = []
