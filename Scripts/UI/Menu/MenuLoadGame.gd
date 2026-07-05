extends Control

@export var buttons: Array[GuiDancingLabel]
var scene_game: PackedScene = preload("uid://bq17dmqps7w6c")

func _ready() -> void:
	for button in buttons:
		button.mouse_entered.connect(func(): _on_entered_button(button))
		button.mouse_exited.connect(func(): _on_exited_button(button))
		button.gui_input.connect(_start_game)


func _start_game(event: InputEvent):
	if MainMenu.is_not_click(event):
		return
	get_tree().change_scene_to_packed(scene_game)


func _on_entered_button(button: GuiDancingLabel):
	button.dance()


func _on_exited_button(button: GuiDancingLabel):
	button.stop()
