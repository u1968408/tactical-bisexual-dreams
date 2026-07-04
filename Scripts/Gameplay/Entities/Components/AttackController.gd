class_name AttackController
extends EntityNode


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
