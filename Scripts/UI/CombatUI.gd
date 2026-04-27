extends AnimatedSprite2D
class_name CombatUI

class AnimationNames:
	const MOVE: String = "move"
	const ATTACK: String = "attack"
	const NONE: String = "none"
	
	static func FromState(value: CombatState) -> String:
		match value:
			CombatUI.CombatState.Move:
				return MOVE
			CombatUI.CombatState.Attack:
				return ATTACK
			CombatUI.CombatState.None:
				return NONE
		return NONE

class CustomAnim:
	var anim_name: String
	var play_backwards: bool
	var state: CombatState
	func _init(anim: String, combat_state: CombatState, backwards: bool = false) -> void:
		anim_name = anim
		play_backwards = backwards
		state = combat_state

enum CombatState {
	None = 0,
	Move = 1,
	Attack = 2,
}

const POSSIBLE_STATES: Array[CombatState] = [
	CombatState.Move,
	CombatState.Attack,
]
const MAX_QUEUE: int = 4

signal state_changed(new: CombatState)

var _animation_queue: Array[CustomAnim] = []
@onready var _input: InputController = %InputController
var current_animation: CustomAnim

var active: bool = false:
	get:
		return active
	set(value):
		active = value
		if not value:
			_SafeQueueDelete()
			state = CombatState.None

var state: CombatState = CombatState.None:
	get:
		return state
	set(value):
		if _animation_queue.size() >= MAX_QUEUE:
			return
		if value == state:
			return
		var prev_anim := AnimationNames.FromState(state)
		_animation_queue.append(CustomAnim.new(prev_anim, state, true))
		var next_anim := AnimationNames.FromState(value)
		_animation_queue.append(CustomAnim.new(next_anim, value, false))
		state = value
		if not is_playing():
			_OnAnimationFinished()

func _ready() -> void:
	_input.combat_ui_direction.connect(OnChangeDirection)
	_input.combat_ui_by_id.connect(OnChangeById)
	animation_finished.connect(_OnAnimationFinished)
	
func _OnAnimationFinished() -> void:
	if current_animation != null and not current_animation.play_backwards:
		state_changed.emit(current_animation.state)
	if _animation_queue.is_empty():
		return
	current_animation = _animation_queue.pop_front()
	if current_animation.play_backwards:
		play_backwards(current_animation.anim_name)
	else:
		play(current_animation.anim_name)

func _SafeQueueDelete() -> void:
	
	if _animation_queue.is_empty():
		return
	var next: CustomAnim = _animation_queue[0]
	if next.play_backwards:
		# El deixem perque aixi torna a l'estat base
		_animation_queue.resize(1)
	else:
		_animation_queue = []

func OnChangeDirection(direction: int) -> void:
	if not active:
		return
	var new_index := wrapi(state + direction, 0, POSSIBLE_STATES.size())
	state = POSSIBLE_STATES[new_index]
	print("Changed to %s" % state)

func OnChangeById(id: int) -> void:
	if not active:
		return
	if not id in CombatState.values():
		push_error("S'ha intentat habilitar un CombatState que no existeix (%s)." % id)
		return
	
	state = id as CombatState 
	print("Changing to state %s" % id)
