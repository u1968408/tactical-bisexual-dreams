class_name GuiStatContainer
extends TextureRect

@export var icon: Texture2D
@export var type: Stats.StatType

@export var label_type: Label
@export var label_value: Label
@export var icon_container: TextureRect
@export var modified_label: Label

var stat_name: String:
	get:
		return Stats.get_stat_name(type)


func _ready() -> void:
	icon_container.texture = icon
	label_type.text = stat_name
	label_value.text = ""


func set_values(value: int, base_value: int) -> void:
	label_value.text = str(base_value)
	set_modified(value - base_value)


func set_modified(value: int):
	if value > 0:
		modified_label.text = "+%s" % value
	elif value < 0:
		modified_label.text = str(value)
	else:
		modified_label.text = ""
