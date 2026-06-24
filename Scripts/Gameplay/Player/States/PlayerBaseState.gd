@abstract
class_name PlayerBaseState extends State

@onready var player: PlayerController = _get_player()
@onready var board: Board = %Board

func _get_player() -> PlayerController:
	var parent := state_machine.get_parent()
	if parent is not PlayerController:
		push_error("El pare de la StateMachine de l'estat %s no és un PlayerController (parent: %s)." \
		% [name, parent.name])
		return null
	return parent

func add_listeners() -> void:
	super()
	InputController.mouse_hover.connect(on_mouse_move)
	InputController.mouse_click.connect(on_mouse_click)
	InputController.mouse_secondary_click.connect(on_mouse_secondary_click)

func remove_listeners() -> void:
	super()
	if InputController == null:
		return
	_safe_disconnect(on_mouse_move, InputController.mouse_hover)
	_safe_disconnect(on_mouse_click, InputController.mouse_click)
	_safe_disconnect(on_mouse_secondary_click, InputController.mouse_secondary_click)

func _safe_disconnect(callable: Callable, target_signal: Signal):
	if target_signal.is_connected(callable):
		target_signal.disconnect(callable)

@abstract
func on_mouse_move(_screen_position: Vector2, tile_position: Vector3)

@abstract
func on_mouse_click() -> void

func on_mouse_secondary_click() -> void:
	pass
