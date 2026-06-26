class_name SelectableAction
extends TextureRect

signal selected(action_type: CombatUtils.Actions)

const COLOR_TINT: Color = Color("#949494")
const GROW_SIZE: Vector2 = Vector2(1.25, 1.25)
const ANIMATION_DURATION: float = 0.10

@export var type: CombatUtils.Actions
@export var label: GuiSelectableActionLabel
@export var area: GuiSelectableActionArea
@export var polygon: Control

var is_selected: bool:
	get:
		return _selected

var _selected: bool = false


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


func trigger_selected() -> void:
	print("Collided with type %s" % type)
	selected.emit(type)


func select():
	_selected = true
	modulate = Color.WHITE
	label.dance()
	label.inverted_color()

	var tween: Tween = create_tween()
	tween.tween_property(polygon, "scale", Vector2.ONE, ANIMATION_DURATION)


func unselect():
	_selected = false
	_on_mouse_exited()
	label.stop()
	label.default_color()

	var tween: Tween = create_tween()
	tween.tween_property(polygon, "scale", Vector2.ZERO, ANIMATION_DURATION)


func _on_mouse_entered() -> void:
	_animate_hover()
	label.dance()


func _on_mouse_exited() -> void:
	_animate_exit()

	if not _selected:
		label.stop()


func _animate_hover():
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, ANIMATION_DURATION)
	tween.tween_property(self, "scale", GROW_SIZE, ANIMATION_DURATION)


func _animate_exit():
	var tween: Tween = create_tween()
	tween.set_parallel(true)

	if not _selected:
		tween.tween_property(self, "modulate", COLOR_TINT, ANIMATION_DURATION)

	tween.tween_property(self, "scale", Vector2.ONE, ANIMATION_DURATION)
