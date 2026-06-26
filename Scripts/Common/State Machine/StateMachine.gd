class_name StateMachine
extends Node

## Getter for the current State in the State machine. Change it via [method set_current_state].
var state: State:
	get:
		return _current_state

var _current_state: State


## Use this async function for changing the State.
## Will call [method State.Exit] for the previous State
## and [method State.Enter] for the new one.
func set_current_state(new_state: State) -> void:
	if _current_state == new_state:
		return

	if _current_state:
		await _current_state.exit()

	_current_state = new_state

	if _current_state:
		await _current_state.enter()

func reset_state() -> void:
	if _current_state == null:
		return
	await _current_state.exit()
	await _current_state.enter()
