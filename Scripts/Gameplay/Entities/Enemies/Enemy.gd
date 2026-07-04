class_name Enemy
extends Entity

signal turn_finished

func execute_turn():
	stats.health = stats.max_health
	await get_tree().create_timer(1.5).timeout
	turn_finished.emit()