class_name MoveBehaviourState
extends EnemyBehaviourState

@export var evaluate_state: EnemyBehaviourState


func enter() -> void:
	super()

	var plan: AttackPlan = attack_plan

	if plan == null:
		state_machine.set_current_state(evaluate_state)
		return

	var path := enemy.board.find_path(
		enemy.board_position,
		plan.attack_position,
		enemy.stats.movement,
	)

	if path.is_empty():
		state_machine.set_current_state(evaluate_state)
		return

	enemy.movement.movement_ended.connect(_on_move_end, ConnectFlags.CONNECT_ONE_SHOT)
	enemy.use_action()
	enemy.move(path)


func _on_move_end():
	state_machine.set_current_state(evaluate_state)
