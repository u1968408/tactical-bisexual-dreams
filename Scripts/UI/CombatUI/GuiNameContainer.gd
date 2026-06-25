class_name GuiNameContainer
extends TextureRect

@export var label: Label

func on_character_changed(character: Character):
	if character == null:
		delete_name()
		return
	change_name(character.character_data.character_name)

func change_name(new_name: String):
	label.text = new_name


func delete_name():
	label.text = ""
