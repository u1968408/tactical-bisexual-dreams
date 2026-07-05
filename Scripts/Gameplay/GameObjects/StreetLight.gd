class_name DestroyableObject
extends Area3D

@export var material_type: WeaponMaterials.MaterialTypes = WeaponMaterials.MaterialTypes.IRON
@export var enable_when_intact: Array[Node3D]
@export var enable_when_destroyed: Array[Node3D]

@export var destroyed: bool:
	get:
		return _destroyed
	set(value):
		_destroyed = value
		_set_visibility_destroyed()

var intact: bool:
	get:
		return not destroyed

var _destroyed: bool = false


func _ready() -> void:
	_set_visibility_destroyed()


func _set_visibility_destroyed():
	for item in enable_when_intact:
		item.visible = intact
	for item in enable_when_destroyed:
		item.visible = destroyed
