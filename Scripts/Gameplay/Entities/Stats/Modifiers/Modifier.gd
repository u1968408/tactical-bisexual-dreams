class_name Modifier
extends Resource

@export var _icon: Texture2D
@export var _modifier_name: String = ""
@export var _type: Stats.StatType
@export var _value: int

var type: Stats.StatType:
	get:
		return _type

var value: int:
	get:
		return _value

var icon: Texture2D:
	get:
		return _icon

var modifier_name: String:
	get:
		return _modifier_name

func create(
	mod_type: Stats.StatType,
	mod_value: int,
	mod_name: String = "",
	mod_icon: Texture2D = null
) -> Modifier:
	var mod: Modifier = Modifier.new()
	mod._type = mod_type
	mod._value = mod_value
	mod._modifier_name = mod_name
	mod._icon = mod_icon
	return mod
