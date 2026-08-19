@abstract
class_name EnemyBehaviourState
extends State

@onready var enemy: Enemy = get_parent().get_parent().get_parent()

@onready var game_manager: GameManager = GameManager.get_current(self)

var attack_plan: AttackPlan:
	get:
		return enemy.behaviour.current_attack_plan
	set(value):
		enemy.behaviour.current_attack_plan = value
