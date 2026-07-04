class_name DisapearShapeCast
extends Area3D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area3D):
	area.visible = false


func _on_area_exited(area: Area3D):
	area.visible = true
