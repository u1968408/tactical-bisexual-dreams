class_name GuiSelectableHability
extends Control

signal clicked_hability(hability: Hability)
signal should_show_description(description: String)

@export var font_color_normal: Color
@export var label: GuiDancingLabel
@export var selected_texture: TextureRect

var active: bool = false
var referenced_hability: Hability

var description:
	get:
		return referenced_hability.description

var _tween: Tween
var _is_hovering: bool = false


func _ready() -> void:
	selected_texture.scale = Vector2.ZERO
	_recalculate_color()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if not active:
		return
	if event is not InputEventMouseButton:
		return
	event = event as InputEventMouseButton
	if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_released():
		clicked_hability.emit(referenced_hability)


func reset() -> void:
	active = false
	label.set_new_text("")
	referenced_hability = null
	selected_texture.scale = Vector2.ZERO
	_recalculate_color()


func set_hability(hability: Hability) -> void:
	active = true
	label.set_new_text(hability.hability_name)
	referenced_hability = hability


func _on_mouse_entered():
	if not active:
		return
	label.dance()
	_is_hovering = true
	_animate()
	_recalculate_color()
	should_show_description.emit(referenced_hability.description)


func _on_mouse_exited():
	label.stop()
	_is_hovering = false
	_animate()
	_recalculate_color()


func _animate():
	if _tween:
		_tween.kill()
	_tween = create_tween()
	var new_size: Vector2 = Vector2.ONE if _is_hovering else Vector2.ZERO
	_tween.tween_property(selected_texture, "scale", new_size, 0.15)


func _recalculate_color():
	if _is_hovering:
		label.remove_theme_color_override("default_color")
	else:
		label.remove_theme_color_override("default_color")
		# label.add_theme_color_override("default_color", font_color_normal)
