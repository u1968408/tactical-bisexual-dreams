@abstract
class_name EnemyBehaviourState
extends State

@onready var enemy: Enemy = _get_parent_enemy()

@onready var game_manager: GameManager = GameManager.get_current(self)

var attack_plan: AttackPlan:
	get:
		return enemy.behaviour.current_attack_plan
	set(value):
		enemy.behaviour.current_attack_plan = value


func _get_parent_enemy() -> Enemy:
	var node: Node = get_parent()

	while node != null:
		if node is Enemy:
			return node

		node = node.get_parent()

	push_error("No s'ha trobat el parent Enemy de %s. Path: %s" % [name, get_path()])
	return null
