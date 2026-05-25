@abstract
extends State
class_name UnitSubState

@onready var master_state: UnitSelectedState = get_parent().get_parent()

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

func Enter() -> void:
	super()
	generator = Generator.new(master_state.board)
	generator.tile_base_color = base_tile_color
	_PrepareRange()

func Exit() -> void:
	super()
	generator = null
	hoovered_tile = null

@abstract
func _PrepareRange() -> void
@abstract
func OnMouseClick() -> void

func OnMouseMove(_p, _wp) -> void:
	pass
