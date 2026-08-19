class_name FindAttackPlanBehaviourState
extends EnemyBehaviourState

@export var attack_state: EnemyBehaviourState
@export var move_state: EnemyBehaviourState
@export var finish_state: EnemyBehaviourState


func enter() -> void:
	super()

	var plan := _find_next_objective()

	if plan == null:
		state_machine.set_current_state(finish_state)
		return

	attack_plan = plan

	if plan.movement_actions == 0:
		state_machine.set_current_state(attack_state)
	else:
		state_machine.set_current_state(move_state)


func _find_next_objective() -> AttackPlan:
	var max_movement_actions := maxi(enemy.current_actions - 1, 0)

	var reachable_tiles := enemy.board.get_reachable_tiles(
		enemy.board_position,
		enemy.stats.movement,
		max_movement_actions,
	)

	var plans: Array[AttackPlan] = []

	for character in game_manager.characters:
		if not is_instance_valid(character):
			continue

		plans.append_array(_get_attack_plans_for_character(character, reachable_tiles))

	if plans.is_empty():
		return null

	return _select_best_attack_plan(plans)


func _get_attack_plans_for_character(
	character: Character,
	reachable_tiles: Dictionary[Vector2i, int],
) -> Array[AttackPlan]:
	var plans: Array[AttackPlan] = []

	for tile: Vector2i in reachable_tiles:
		var attack_distance := Board.chebyshev_distance(tile, character.board_position)

		if attack_distance > enemy.stats.attack_range:
			continue

		var distance: int = reachable_tiles[tile]

		var movement_actions := 0

		if distance > 0:
			movement_actions = ceili(float(distance) / enemy.stats.movement)

		# Ha de poder atacar després de moure's
		if movement_actions > 0:
			if movement_actions + 1 > enemy.current_actions:
				continue

		var plan := AttackPlan.new()

		plan.character = character
		plan.attack_position = tile
		plan.distance = distance
		plan.movement_actions = movement_actions

		plans.append(plan)

	return plans


func _select_best_attack_plan(plans: Array[AttackPlan]) -> AttackPlan:
	var best: AttackPlan = null

	for plan in plans:
		if best == null:
			best = plan
			continue

		# 1. Menys accions per moure's
		if plan.movement_actions < best.movement_actions:
			best = plan
			continue

		if plan.movement_actions > best.movement_actions:
			continue

		# 2. Objectiu amb menys vida
		if plan.character.stats.health < best.character.stats.health:
			best = plan
			continue

		if plan.character.stats.health > best.character.stats.health:
			continue

		# 3. Menys moviment
		if plan.distance < best.distance:
			best = plan

	return best
