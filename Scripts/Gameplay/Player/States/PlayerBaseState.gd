@abstract
extends State
class_name PlayerBaseState

@onready var player: PlayerController = __get_player()
@onready var input_controller: InputController = %InputController
@onready var board: Board = %Board

func __get_player() -> PlayerController:
	var parent := state_machine.get_parent()
	if parent is not PlayerController:
		push_error("El pare de la StateMachine de l'estat %s no és un PlayerController (parent: %s)." \
		% [name, parent.name])
		return null
	return parent

func AddListeners() -> void:
	super()
	input_controller.mouse_hover.connect(on_mouse_move)
	input_controller.mouse_click.connect(on_mouse_click)
	input_controller.mouse_secondary_click.connect(on_mouse_secondary_click)

func RemoveListeners() -> void:
	super()
	if input_controller == null:
		return
	__safe_disconnect(on_mouse_move, input_controller.mouse_hover)
	__safe_disconnect(on_mouse_click, input_controller.mouse_click)
	__safe_disconnect(on_mouse_secondary_click, input_controller.mouse_secondary_click)

func __safe_disconnect(callable: Callable, target_signal: Signal):
	if target_signal.is_connected(callable):
		target_signal.disconnect(callable)

@abstract
func on_mouse_move(_screen_position: Vector2, tile_position: Vector3)

@abstract
func on_mouse_click() -> void

func on_mouse_secondary_click() -> void:
	pass
