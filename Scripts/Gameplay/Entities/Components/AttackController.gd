extends EntityNode
class_name AttackController


func Attack(other: Entity):
	entity.current_state = Entity.EntityState.Attacking
	other.stats.health -= entity.stats.damage
	entity.weapons.PlayAttackAnimation()
	print("Attacking by %s damage to %s. Health: %s" % [entity.stats.damage, other.name, other.stats.health])

