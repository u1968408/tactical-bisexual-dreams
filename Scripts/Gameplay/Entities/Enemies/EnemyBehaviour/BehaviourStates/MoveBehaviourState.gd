class_name MoveBehaviourState
extends EnemyBehaviourState

@export var evaluate_state: EnemyBehaviourState


func enter() -> void:
	super()

	var plan: AttackPlan = attack_plan

	if plan == null:
		push_warning("Ha arribat a Move Behaviour sense un pla per executar.")
		state_machine.set_current_state(evaluate_state)
		return

	if enemy.board_position == plan.attack_position:
		state_machine.set_current_state(evaluate_state)
		return

	var full_path := enemy.board.find_path(
		enemy.board_position,
		plan.attack_position
	)

	if full_path.is_empty():
		push_warning(
            "Camí impossible de %s a %s"
			% [enemy.board_position, plan.attack_position]
		)
		attack_plan = null
		call_deferred("_reevaluate")
		return

	var steps := mini(enemy.stats.movement, full_path.size() - 1)
	var movement_path := full_path.slice(0, steps + 1)

	enemy.use_action()

	enemy.movement.movement_ended.connect(
		_on_move_end,
		CONNECT_ONE_SHOT
	)

	enemy.move(movement_path)


func _reevaluate() -> void:
	state_machine.set_current_state(evaluate_state)


func _on_move_end() -> void:
	state_machine.set_current_state(evaluate_state)
