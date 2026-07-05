class_name Token
extends Area3D

signal finished_travel

@export var mesh: MeshInstance3D
@export var speed: float = 13

var _character: Character
var _follow: PathFollow3D


func _process(_delta: float) -> void:
	if _follow:
		global_position = _follow.global_position


func create_from_character(character: Character) -> Token:
	_character = character
	var token = duplicate()
	token.visible = false
	Board.instance.add_child(token)
	return token


func throw_along_path(follow_path: PathFollow3D):
	visible = true
	_follow = follow_path
	var tween := create_tween()
	_follow.progress_ratio = 0
	var p: Path3D = _follow.get_parent()
	var time: float = p.curve.get_baked_length() / speed
	tween.tween_property(_follow, "progress_ratio", 1, time)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(_finished_travel)


func _finished_travel():
	monitorable = true
	_follow = null

	finished_travel.emit()
	print("travel finished")
