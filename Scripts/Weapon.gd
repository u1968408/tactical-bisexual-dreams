class_name Weapon
extends Resource

enum WTypes {
	NONE,
	RANGED,
	SHORT,
	BALANCED,
	LARGE,
}

@export var name: String
@export var sprite: SpriteFrames
@export var attack_range: int = 1
@export var damage: int = 15
@export var type: WTypes = WTypes.BALANCED
