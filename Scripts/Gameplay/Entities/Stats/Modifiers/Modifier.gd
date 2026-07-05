class_name Modifier
extends Resource

@export var _type: Stats.StatType
@export var _value: int

var type: Stats.StatType:
	get:
		return _type

var value: int:
	get:
		return _value


func create(
	mod_type: Stats.StatType,
	mod_value: int,
) -> Modifier:
	var mod: Modifier = Modifier.new()
	mod._type = mod_type
	mod._value = mod_value
	return mod
