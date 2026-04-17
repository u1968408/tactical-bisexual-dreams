extends PlayerBaseState
class_name UnitSelectedState

@export var free_select_state: FreeSelectPlayerState

var current_entity: Entity = null
var generator: Generator

func Enter() -> void:
	super()
	generator = Generator.new(board)
	if current_entity == null:
		push_error("S'ha entrat al estat de unitat seleccionada sense seleccionar unitat.")
		state_machine.setCurrentState(free_select_state)
		return
	if current_entity is Character:
		print("Creating characters")
		generator.GenerateTilesArroundPosition(
			current_entity.board_position,
			current_entity.stats.movement
		)
		

func Exit():
	super()
	generator = null

func AddListeners():
	super()

func RemoveListeners():
	super()

func on_mouse_move(_screen_position: Vector2, _tile_position: Vector3):
	pass

func on_mouse_click() -> void:
	pass
