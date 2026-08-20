class_name AttackController
extends EntityNode

signal attack_finished

@export var attack_result_feedback_scene: PackedScene

var attack_result_feedback: AttackResultFeedback


func _ready() -> void:
	attack_result_feedback = attack_result_feedback_scene.instantiate()
	entity.add_child(attack_result_feedback)


func get_attack_preview(other: Entity) -> AttackPreview:
	var final_damage: int = other.stats.calculate_damage_after_resistance(entity.stats.damage)

	var hit_chance: int = other.stats.calculate_hit_chance(entity)

	return AttackPreview.new(hit_chance, final_damage)


func attack(other: Entity):
	entity.current_state = Entity.EntityState.ATTACKING

	var result := resolve_attack(other)

	entity.look_at_direction(other.global_position)
	other.look_at_direction(entity.global_position)

	if result.hit:
		other.stats.health -= result.damage
		other.current_state = Entity.EntityState.HURT

		print(
			"Attack hit %s for %s damage. Health: %s"
			% [other.name, result.damage, other.stats.health]
		)
	else:
		print("Attack missed %s" % other.name)

	attack_result_feedback.show_result(result)

	if entity.animation_player != null:
		entity.animation_player.attack_finished.connect(
			_on_attack_animation_finished,
			ConnectFlags.CONNECT_ONE_SHOT,
		)
	else:
		print("No animation player on %s" % entity.name)
		_on_attack_animation_finished()


func resolve_attack(other: Entity) -> AttackResult:
	var hit_chance := other.stats.calculate_hit_chance(entity)

	var roll := randi_range(1, 100)
	var hit := roll <= hit_chance

	if not hit:
		return AttackResult.new(false, 0)

	var damage := Stats.calculate_damage_after_resistance(
		entity.stats.damage,
		other.stats.resistance,
	)

	return AttackResult.new(true, damage)


func _on_attack_animation_finished() -> void:
	attack_finished.emit()
