@abstract class_name UnitSubState
extends State

@export var base_tile_color: Color

var generator: Generator

var character: Character:
	get:
		return master_state.current_character

var hoovered_tile: Tile:
	get:
		return master_state.current_tile
	set(value):
		master_state.current_tile = value

@onready var master_state: UnitSelectedState = get_parent().get_parent()


func enter() -> void:
	super()
	generator = Generator.new(master_state.board)
	generator.tile_base_color = base_tile_color
	prepare_range()


func exit() -> void:
	super()
	generator = null
	hoovered_tile = null


@abstract func prepare_range() -> void

@abstract func on_mouse_click() -> void


func on_mouse_move(_p, _wp) -> void:
	pass


func _reset_if_possible():
	if character.has_actions():
		state_machine.reset_state()
		return
	master_state.return_to_select_state()
