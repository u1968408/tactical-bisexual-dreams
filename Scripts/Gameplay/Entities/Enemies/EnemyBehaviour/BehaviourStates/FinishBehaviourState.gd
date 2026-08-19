extends EnemyBehaviourState


func enter() -> void:
	super()
	attack_plan = null
	print("BEFORE FINISH TURN: %s" % enemy.name)
	enemy.finish_turn()
	print("AFTER FINISH TURN: %s" % enemy.name)
