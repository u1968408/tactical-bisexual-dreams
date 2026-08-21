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
