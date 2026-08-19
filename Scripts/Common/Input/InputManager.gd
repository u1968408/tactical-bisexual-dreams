class_name InputManager
extends Node

enum InputType {
	CAMERA,
	BOARD,
	COMBAT,
}

const INPUT_SCRIPTS := {
	InputType.CAMERA: preload("uid://c4wwy3prtqrjr"),
	InputType.BOARD: preload("uid://c0c26scfashg1"),
	InputType.COMBAT: preload("uid://c8xv8fsaihaj4"),
}


@export_flags(
	"Camera",
	"Board",
	"Combat"
)
var enabled_inputs: int


func _ready() -> void:
	for input_type in InputType.values():
		if not _is_enabled(input_type):
			continue

		_create_input(input_type)


func _create_input(input_type: InputType) -> Node:
	var script: Script = INPUT_SCRIPTS[input_type]
	var input_node: Node = script.new()

	add_child(input_node)

	return input_node


func _is_enabled(input_type: InputType) -> bool:
	return (enabled_inputs & (1 << input_type)) != 0