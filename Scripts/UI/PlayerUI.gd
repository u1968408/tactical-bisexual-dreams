class_name PlayerUI
extends Control

signal passed_turn

const POS_TURN_HIDDEN: Vector2 = Vector2(2000.0, 809.0)
const POS_TURN_SHOW: Vector2 = Vector2(1726.0, 949.0)


@export var pass_turn: Control
@export var turn_message: GuiTurnMessage

var player_ui_active: bool:
	get:
		return _player_ui_active
	set(value):
		_player_ui_active = value
		if _player_ui_active:
			pass_turn.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			pass_turn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_animate_pass_turn()

var _player_ui_active: bool

var _tween_pass_turn: Tween

func player_in():
	turn_message.player_in()
	player_ui_active = true

func player_out():
	player_ui_active = false

func enemy_in():
	turn_message.enemy_in()

func enemy_out():
	pass

func _ready() -> void:
	pass_turn.gui_input.connect(_on_pass_turn_clicked)
	pass_turn.position = POS_TURN_HIDDEN


func _on_pass_turn_clicked(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var evt: InputEventMouseButton = event as InputEventMouseButton
	if evt.button_index != MOUSE_BUTTON_LEFT or not evt.is_released():
		return
	passed_turn.emit()

func _animate_pass_turn():
	pass_turn.visible = true
	if _tween_pass_turn:
		_tween_pass_turn.kill()
	_tween_pass_turn = create_tween()
	var pos: Vector2 = POS_TURN_SHOW if player_ui_active else POS_TURN_HIDDEN
	_tween_pass_turn.tween_property(pass_turn, "position", pos, 0.2)
	if not player_ui_active:
		_tween_pass_turn.finished.connect(func(): pass_turn.visible = false)
