extends EnemyBehaviourState


func enter() -> void:
	super()
	attack_plan = null
	enemy.finish_turn()
