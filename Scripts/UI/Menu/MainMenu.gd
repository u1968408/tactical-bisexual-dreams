class_name MainMenu
extends Control

const MODULATE_GRAY: Color = Color("#a3a3a3")
const SCALE_MIN: Vector2 = Vector2(0.8, 0.8)

@export var player: AnimationPlayer
@export var back_button: Control
@export var credits: Control
@export var exit: Control
@export var play: Control

var buttons: Array[Control]:
	get:
		return [
			credits,
			exit,
			play,
			back_button,
		]

var _tweens: Dictionary[int, Tween] = {}


func _ready() -> void:
	for button in buttons:
		button.mouse_entered.connect(func(): _on_entered_button(button))
		button.mouse_exited.connect(func(): _on_exited_button(button))
		button.modulate = MODULATE_GRAY
		button.scale = SCALE_MIN
	play.gui_input.connect(_on_play)
	credits.gui_input.connect(_on_credits)
	exit.gui_input.connect(_on_exit)
	back_button.gui_input.connect(_on_back)


func _on_play(event: InputEvent):
	if is_not_click(event):
		return
	player.play("start_game")


func _on_credits(event: InputEvent):
	if is_not_click(event):
		return
	player.play("credits")


func _on_exit(event: InputEvent):
	if is_not_click(event):
		return
	get_tree().quit()


func _on_back(event: InputEvent):
	if is_not_click(event):
		return
	var current_anim: String = player.current_animation
	player.play_backwards(current_anim)


static func is_not_click(event: InputEvent) -> bool:
	if event is not InputEventMouseButton:
		return true
	var evt: InputEventMouseButton = event as InputEventMouseButton
	if evt.button_index != MOUSE_BUTTON_LEFT or not evt.is_released():
		return true
	return false


func _on_entered_button(button: Control):
	_animate_button(button, true)


func _on_exited_button(button: Control):
	_animate_button(button, false)


func _animate_button(button: Control, hover: bool):
	var tween: Tween = _tweens.get(button.get_instance_id(), null)
	if tween:
		tween.kill()
	tween = create_tween()
	var new_scale: Vector2 = Vector2.ONE if hover else SCALE_MIN
	var new_color: Color = Color.WHITE if hover else MODULATE_GRAY
	tween.tween_property(button, "scale", new_scale, 0.15)
	tween.tween_property(button, "modulate", new_color, 0.15)
	_tweens.set(button.get_instance_id(), tween)
