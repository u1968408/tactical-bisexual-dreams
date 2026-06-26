class_name GuiStatContainer
extends TextureRect

@export var icon: Texture2D
@export var type: Stats.StatType

@export var label_type: Label
@export var label_value: Label
@export var icon_container: TextureRect

var stat_name: String:
	get:
		return Stats.get_stat_name(type)


func _ready() -> void:
	icon_container.texture = icon
	label_type.text = stat_name
	label_value.text = ""


func set_value(value: int) -> void:
	label_value.text = str(value)
