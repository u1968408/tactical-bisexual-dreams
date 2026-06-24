class_name Modifier
extends RefCounted

var type: Stats.StatType:
	get:
		return _type

var value: int:
	get:
		return _value

var _type: Stats.StatType
var _value: int


func _init(
	mod_type: Stats.StatType,
	mod_value: int,
) -> void:
	_type = mod_type
	_value = mod_value
