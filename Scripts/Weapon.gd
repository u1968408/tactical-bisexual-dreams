extends Resource
class_name Weapon

enum WTypes {
	Ranged,
	Light,
	Balanced,
	Heavy,
}

@export var name: String
@export var sprite: SpriteFrames
@export var attack_range: int = 1
@export var damage: int = 15
@export var type: WTypes = WTypes.Balanced
