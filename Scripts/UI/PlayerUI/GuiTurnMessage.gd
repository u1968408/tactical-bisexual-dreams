class_name GuiTurnMessage
extends Control

@export var label: Label

var _tween: Tween

func player_in():
	label.text = "PLAYER TURN"
	_animate()


func enemy_in():
	label.text = "ENEMY TURN"
	_animate()


func _animate():
	print("aniomation")
	rotation_degrees = 45
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "rotation_degrees", 0, 0.3)
	_tween.tween_interval(1.0)
	_tween.tween_property(self, "rotation_degrees", -45, 0.3)
	_tween.tween_callback(func(): visible = false)
