class_name GuiSelectableWeaponType
extends TextureRect

signal clicked(type: Weapon.WTypes)

const COLOR_TINT: Color = Color("#949494")
const GROW_SIZE: Vector2 = Vector2(1.25, 1.25)
const ANIMATION_DURATION: float = 0.10

@export var start_position_node: Node2D
@export var type: Weapon.WTypes

var active: bool:
	get:
		return _active
	set(value):
		_active = value
		_animate_activate()
		if _active:
			mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			mouse_filter = Control.MOUSE_FILTER_IGNORE

var _tween: Tween
var _tween_activate: Tween
var _start_position: Vector2
var _final_position: Vector2
var _active: bool


func _ready() -> void:
	modulate = COLOR_TINT
	_start_position = start_position_node.position
	_final_position = position
	position = _start_position
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if not active:
		return

	if event is not InputEventMouseButton:
		return

	var evt := event as InputEventMouseButton
	if evt.button_index != MOUSE_BUTTON_LEFT or not evt.is_released():
		return
	clicked.emit(type)
	accept_event()


func _animate_activate():
	visible = true
	var new_pos = _final_position if _active else _start_position
	if _tween_activate:
		_tween_activate.kill()
	_tween_activate = create_tween()
	_tween_activate.tween_property(self, "position", new_pos, 0.3)
	if not _active:
		_tween_activate.tween_callback(func(): visible = false)


func _on_mouse_entered():
	if not active:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate", Color.WHITE, ANIMATION_DURATION)
	_tween.tween_property(self, "scale", GROW_SIZE, ANIMATION_DURATION)


func _on_mouse_exited():
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate", COLOR_TINT, ANIMATION_DURATION)
	_tween.tween_property(self, "scale", Vector2.ONE, ANIMATION_DURATION)
