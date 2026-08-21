class_name Torus
extends Node3D

signal finished

@export var animation_player: AnimationPlayer
@export var taurus: MeshInstance3D

var color: Color:
	get:
		return material.albedo_color
	set(value):
		material.albedo_color = value

var material:
	get:
		if _material == null:
			_material = taurus.get_active_material(0)
		return _material

var _material: Material


func play_animation():
	animation_player.animation_finished.connect(_on_finish, ConnectFlags.CONNECT_ONE_SHOT)
	animation_player.play("buff")


func _on_finish(_anim_name: String):
	finished.emit()
