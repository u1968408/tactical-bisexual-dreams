class_name Enemy
extends Entity

@export var behaviour: EnemyBehaviour


## Senyal que s'emet quan l'enemic ha acabat el seu torn.
signal turn_finished


func execute_turn():
	await get_tree().process_frame
	behaviour.execute()


func finish_turn():
	behaviour.finish()
	turn_finished.emit()
