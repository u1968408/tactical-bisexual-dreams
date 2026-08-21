class_name CharacterHealthContainer

extends Control

@export var health_label: Label
@export var health_bar: TextureProgressBar
@export var entity: Entity

@export_group("Visibility")
@export var show_only_when_damaged: bool = false
@export var damaged_visible_time: float = 1.5
@export var fade_in_duration: float = 0.15
@export var fade_out_duration: float = 0.5

var _health: int:
	set(value):
		print("setting health to %s" % value)
		health_bar.value = value
		health_label.text = str(value)

var _max_health: int:
	set(value):
		health_bar.max_value = value

var _hide_timer: Timer
var _fade_tween: Tween


func _ready() -> void:
	if entity == null:
		push_error("No s'ha connectat %s amb %s" % [self.name, get_parent().name])
	await entity.ready

	_max_health = entity.stats.max_health
	_set_current_health(0, entity.stats.health)

	entity.stats.health_changed.connect(_set_current_health)

	if show_only_when_damaged:
		modulate.a = 0.0

		_hide_timer = Timer.new()
		_hide_timer.one_shot = true
		_hide_timer.timeout.connect(_fade_out)
		add_child(_hide_timer)


func _process(_delta: float) -> void:
	if modulate.a <= 0.0:
		return

	global_position = entity.interface_position + Vector2(-get_rect().size.x / 2, 0)


func _set_current_health(change_value: int, new_health: int) -> void:
	_health = new_health

	if show_only_when_damaged and change_value < 0:
		_show_for_damage()


func _show_for_damage() -> void:
	# Reinicia el timer cada vez que recibe daño.
	_hide_timer.start(damaged_visible_time)

	# Mata el tween anterior para evitar conflictos.
	if _fade_tween:
		_fade_tween.kill()

	# Fade-in.
	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_QUAD)
	_fade_tween.set_ease(Tween.EASE_OUT)
	_fade_tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)


func _fade_out() -> void:
	if _fade_tween:
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_QUAD)
	_fade_tween.set_ease(Tween.EASE_IN)
	_fade_tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)
