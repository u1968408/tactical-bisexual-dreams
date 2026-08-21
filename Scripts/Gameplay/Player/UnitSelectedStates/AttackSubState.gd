class_name AttackSubState
extends UnitSubState

@export var preview_container_scene: PackedScene 
var preview_container: AttackPreviewContainer

var preview_entity: Entity:
	get:
		return _preview_entity
	set(value):
		if value == _preview_entity:
			return
		_preview_entity = value

		if is_instance_valid(preview_container):
			preview_container.queue_free()
			preview_container = null

		if _preview_entity == null:
			return

		if preview_container_scene != null and master_state and master_state.combat_ui:
			preview_container = preview_container_scene.instantiate() as AttackPreviewContainer
			master_state.combat_ui.add_child(preview_container)
			preview_container.configure(character, _preview_entity)
			_update_preview_position()

var _preview_entity: Entity


func prepare_range() -> void:
	generator.use_astar = false
	generator.generate_tiles_arround_position(
		character.board_position,
		character.stats.attack_range,
	)


func on_mouse_move(_screen_position: Vector2, _world_position: Vector3) -> void:
	var tile := hoovered_tile
	if not tile or tile.current_entity == null:
		preview_entity = null
		return

	preview_entity = tile.current_entity
	_update_preview_position()


func on_mouse_click() -> void:
	var tile := hoovered_tile
	if not tile or tile.current_entity == null:
		print("No attack target!")
		return
	character.attack.attack(tile.current_entity)
	character.use_action()
	preview_entity = null
	_reset_if_possible()


func _update_preview_position() -> void:
	if is_instance_valid(preview_container) and preview_container.visible:
		var mouse_pos := preview_container.get_global_mouse_position()
		preview_container.global_position = mouse_pos
