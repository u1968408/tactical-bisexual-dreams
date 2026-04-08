@tool
extends Sprite3D

@onready var _camera: Camera3D = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
	var camera_pos: Vector3 = _camera.global_position
	look_at(camera_pos, Vector3(0, 1, 0), true)
