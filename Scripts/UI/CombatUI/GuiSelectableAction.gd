class_name SelectableAction
extends TextureRect

signal finished_animation_select(type: CombatUtils.Actions)

const COLOR_TINT: Color = Color("#949494")
const GROW_SIZE: Vector2 = Vector2(1.25, 1.25)
const ANIMATION_DURATION: float = 0.10

@export var type: CombatUtils.Actions
@export var label: GuiDancingLabel
@export var area: GuiSelectableActionArea
@export var polygon: Control

var enabled: bool:
	get:
		return _enabled
	set(value):
		_enabled = value
		area.input_pickable = _enabled
		if not _enabled:
			modulate = COLOR_TINT

var is_selected: bool:
	get:
		return _is_selected

var _is_selected: bool = false
var _enabled: bool = true
var _tween: Tween
var _tween_selected: Tween


func _ready() -> void:
	modulate = COLOR_TINT
	polygon.scale = Vector2.ZERO

	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)


func contains_viewport_point(viewport_point: Vector2) -> bool:
	if area == null:
		return false

	var col: CollisionPolygon2D = area.collision
	if col == null:
		return false

	var canvas_point := col.get_canvas_transform().affine_inverse() * viewport_point
	var point_in_collision_space := col.to_local(canvas_point)

	return Geometry2D.is_point_in_polygon(point_in_collision_space, col.polygon)


func select():
	_is_selected = true
	if _tween:
		_tween.kill()
	modulate = Color.WHITE
	label.dance()
	label.inverted_color()
	_animate_selected()


func _animate_selected():
	var new_scale: Vector2 = Vector2.ONE if is_selected else Vector2.ZERO
	print("Selected action %s" % type)
	if _tween_selected:
		_tween_selected.kill()
	_tween_selected = create_tween()
	_tween_selected.tween_property(polygon, "scale", new_scale, ANIMATION_DURATION)
	if is_selected:
		_tween_selected.tween_callback(finished_animation_select.emit.bind(type))


func unselect():
	_is_selected = false
	_on_mouse_exited()
	label.stop()
	label.default_color()

	_animate_selected()


func _on_mouse_entered() -> void:
	_animate_hover()
	label.dance()


func _on_mouse_exited() -> void:
	_animate_exit()

	if not _is_selected:
		label.stop()


func _animate_hover():
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate", Color.WHITE, ANIMATION_DURATION)
	_tween.tween_property(self, "scale", GROW_SIZE, ANIMATION_DURATION)


func _animate_exit():
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)

	if not _is_selected:
		_tween.tween_property(self, "modulate", COLOR_TINT, ANIMATION_DURATION)

	_tween.tween_property(self, "scale", Vector2.ONE, ANIMATION_DURATION)
