class_name EvaluateBehaviourState
extends EnemyBehaviourState

@export var finish_state: EnemyBehaviourState
@export var find_attack_state: EnemyBehaviourState


func enter() -> void:
	super()

	if enemy.current_actions <= 0:
		state_machine.set_current_state(finish_state)
		return

	state_machine.set_current_state(find_attack_state)
