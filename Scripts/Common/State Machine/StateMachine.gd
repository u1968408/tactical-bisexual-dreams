class_name StateMachine
extends Node

var _currentState: State

## Getter for the current State in the State machine. Change it via [method setCurrentState].
var state: State:
	get:
		return _currentState

## Use this async function for changing the State.
## Will call [method State.Exit] for the previous State
## and [method State.Enter] for the new one.
func setCurrentState(newState: State) -> void:
	if _currentState == newState:
		return

	if _currentState:
		await _currentState.Exit()

	_currentState = newState
	
	if _currentState:
		await _currentState.Enter()
