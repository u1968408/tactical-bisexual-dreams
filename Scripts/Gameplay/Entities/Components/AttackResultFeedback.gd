class_name AttackResultFeedback
extends Control


@onready var miss_feedback: Control = $MissFeedback
@onready var damage_popup: Control = $DamagePopup


func show_result(result: AttackResult) -> void:
	if result.hit:
		_show_damage(result.damage)
	else:
		_show_miss()


func _show_miss() -> void:
	miss_feedback.visible = true
	damage_popup.visible = false

	miss_feedback.modulate.a = 0.0

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		miss_feedback,
		"modulate:a",
		1.0,
		0.15
	)

	tween.tween_interval(0.4)

	tween.tween_property(
		miss_feedback,
		"modulate:a",
		0.0,
		0.2
	)

	await tween.finished
	miss_feedback.visible = false


func _show_damage(amount: int) -> void:
	damage_popup.visible = true
	miss_feedback.visible = false

	damage_popup.get_node("Label").text = "-%d" % amount

	damage_popup.modulate.a = 1.0

	var start_position := damage_popup.position
	var end_position := start_position + Vector2.UP * 40.0

	damage_popup.position = start_position

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		damage_popup,
		"position",
		end_position,
		0.7
	)

	tween.tween_property(
		damage_popup,
		"modulate:a",
		0.0,
		0.7
	)

	await tween.finished
	damage_popup.visible = false