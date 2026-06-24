class_name GuiSelectableActionArea
extends Area2D

var debug_point := Vector2.ZERO
var has_debug_point := false

var collision: CollisionPolygon2D:
	get:
		if _collision == null:
			for child in get_children():
				if child is CollisionPolygon2D:
					_collision = child
					break
		return _collision

var _collision: CollisionPolygon2D


func _ready() -> void:
	if collision == null:
		push_warning("No CollisionPolygon2D found")
		return
