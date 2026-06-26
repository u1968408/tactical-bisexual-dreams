class_name GuiStatsContainer
extends VBoxContainer

const SHOW_POSITION_X: float = 15
const HIDDEN_POSITION_X: float = -282.0

@export_range(0, 1, 0.01) var delay_time: float = 0.3

var active: bool:
	get:
		return _active
	set(value):
		_active = value
		if _active:
			_on_activate()
		else:
			_on_deactivate()

var stats: Array[GuiStatContainer]:
	get:
		if not _stats:
			_stats = []
			for child in get_children():
				if child is not GuiStatContainer:
					continue
				_stats.append(child)
		return _stats

var _stats: Array[GuiStatContainer]
var _character: Character
var _tween: Tween
var _active: bool = false
var _time_count: float = 0
var _is_showing: bool = false
var _is_wanting_show: bool = false


func _ready() -> void:
	mouse_entered.connect(func(): _is_wanting_show = true)
	mouse_exited.connect(func(): _is_wanting_show = false)


func _process(delta: float) -> void:
	if _is_wanting_show and not _is_showing:
		_time_count += delta
		if _time_count >= delay_time:
			_is_showing = true
			_time_count = 0
			_animate_to_position(SHOW_POSITION_X)
	elif not _is_wanting_show and _is_showing:
		_time_count += delta
		if _time_count >= delay_time:
			_is_showing = false
			_time_count = 0
			_animate_to_position(HIDDEN_POSITION_X)


func _on_activate():
	_animate_to_position(HIDDEN_POSITION_X)


func _on_deactivate():
	var new_pos_x = -size.x - 25
	_animate_to_position(new_pos_x)


func _animate_to_position(new_x: float, callback: Callable = func(): pass):
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	var new_position := position
	new_position.x = new_x
	_tween.tween_property(self, "position", new_position, 0.25)
	_tween.tween_callback(callback)


func _on_combat_ui_character_changed(character: Character) -> void:
	if _character != null and _character.stats.stats_changed.is_connected(_set_current_stats):
		_character.stats.stats_changed.disconnect(_set_current_stats)
	_character = character
	if _character == null:
		return

	_set_current_stats()
	if not _character.stats.stats_changed.is_connected(_set_current_stats):
		_character.stats.stats_changed.connect(_set_current_stats)


func _set_current_stats():
	for container in stats:
		var current_value = _character.stats.get_stat_value(container.type)
		container.set_value(current_value)
