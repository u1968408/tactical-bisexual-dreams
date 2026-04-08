extends Node
class_name CameraComponent

@onready 
var camera: CameraController = get_parent()

func _enter_tree() -> void:
	var parent: Node = get_parent()
	assert(parent is Camera3D, "Error: El pare de %s no és del tipus Camera3D" % name)
