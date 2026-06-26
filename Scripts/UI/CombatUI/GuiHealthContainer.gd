class_name GuiHealthContainer
extends Control

@export var health_label: Label
@export var health_bar: TextureProgressBar

var _character: Character

var _health: int:
	set(value):
		health_bar.value = value
		health_label.text = str(value)

var _max_health: int:
	set(value):
		health_bar.max_value = value


func on_character_changed(character: Character) -> void:
	if _character != null:
		_character.stats.health_changed.disconnect(_set_current_health)
	_character = character
	if character != null:
		_max_health = character.stats.max_health
		_set_current_health(0, character.stats.health)
		character.stats.health_changed.connect(_set_current_health)
	else:
		_max_health = 100
		_set_current_health(0, 0)


func _set_current_health(_change_value: int, new_health: int):
	_health = new_health
