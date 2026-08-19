class_name AttackBehaviourState
extends EnemyBehaviourState

@export var evaluate_state: EnemyBehaviourState


func enter() -> void:
	super()
	var plan: AttackPlan = attack_plan
	if plan == null:
		state_machine.set_current_state(evaluate_state)
		return
	var target := plan.character
	if not is_instance_valid(target):
		state_machine.set_current_state(evaluate_state)
		return
	enemy.attack.attack_finished.connect(_on_attack_finished, ConnectFlags.CONNECT_ONE_SHOT)
	enemy.attack.attack(target)


func _on_attack_finished() -> void:
	enemy.use_action()
	state_machine.set_current_state(evaluate_state)
