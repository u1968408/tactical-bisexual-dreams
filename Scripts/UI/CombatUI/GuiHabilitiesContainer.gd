class_name GuiHabilitiesContainer
extends Control

@export var hability_select_container: TextureRect
@export var hability_containers: Array[GuiSelectableHability]
@export var description_container: TextureRect
@export var description: RichTextLabel

var active: bool:
	get:
		return _active
	set(value):
		_active = value
		_animate()

var _character: Character
var _active: bool
var _tween: Tween


func _ready() -> void:
	description_container.modulate = Color.TRANSPARENT
	hability_select_container.modulate = Color.TRANSPARENT
	_reset_containers()
	for container in hability_containers:
		container.clicked_hability.connect(_on_hability_selected)
		container.should_show_description.connect(_on_show_description)


func _on_hability_selected(hability: Hability) -> void:
	hability._execute()


func _reset_containers():
	description.text = ""
	for container in hability_containers:
		container.reset()


func _on_character_changed(character: Character) -> void:
	if _character == character:
		return
	_reset_containers()
	_character = character
	if _character == null:
		return
	print("Selected character with %s habilities" % len(_character.habilities.habilities))
	var current_idx: int = 0
	for hability in _character.habilities.habilities:
		if current_idx >= len(hability_containers):
			break
		var container: GuiSelectableHability = hability_containers[current_idx]
		container.set_hability(hability)
		current_idx += 1


func _on_show_description(desc: String) -> void:
	description.text = desc


func _animate():
	var new_modulate: Color = Color.WHITE if active else Color.TRANSPARENT
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(description_container, "modulate", new_modulate, 0.1)
	_tween.tween_property(hability_select_container, "modulate", new_modulate, 0.1)
