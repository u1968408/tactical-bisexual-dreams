class_name AttackController
extends EntityNode

signal attack_finished


func attack(other: Entity):
	entity.current_state = Entity.EntityState.ATTACKING
	other.stats.health -= entity.stats.damage
	other.current_state = Entity.EntityState.HURT
	entity.look_at_direction(other.global_position)
	other.look_at_direction(entity.global_position)
	print(
		(
			"Attacking by %s damage to %s. Health: %s"
			% [entity.stats.damage, other.name, other.stats.health]
		)
	)
	if entity.animation_player != null:
		entity.animation_player.attack_finished.connect(
			_on_attack_animation_finished,
			ConnectFlags.CONNECT_ONE_SHOT,
		)
	else:
		print("No animation player on %s" % entity.name)
		_on_attack_animation_finished()


func _on_attack_animation_finished() -> void:
	attack_finished.emit()
