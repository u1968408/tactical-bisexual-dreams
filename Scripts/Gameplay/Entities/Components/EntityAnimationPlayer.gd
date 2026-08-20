class_name EntityAnimationPlayer
extends AnimationPlayer

signal attack_finished

@export var character_sprite: Sprite3D
@export var weapon_sprite: Sprite3D

var sprites: Array[Sprite3D]:
	get:
		return [character_sprite, weapon_sprite]

var _look_suffix: String = "_f"
var _weapon_suffix: String = ""
var _direction: Entity.LookDirection

var _looking_front: bool:
	set(value):
		_look_suffix = "_f" if value else "_b"

var _flip_h: bool = false:
	set(value):
		for sprite in sprites:
			if sprite == null:
				continue
			sprite.flip_h = value

var _attack_animation: String:
	get:
		return "attack" + _weapon_suffix + _look_suffix

var _idle_animation: String:
	get:
		return "idle" + _look_suffix

var _move_animation: String:
	get:
		return "walk" + _look_suffix

var _hurt_animation: String:
	get:
		return "hit" + _look_suffix

var _throw_animation: String:
	get:
		return "throw" + _look_suffix

var _teleport_animation: String:
	get:
		return "teleport" + _look_suffix

var _weapon_type: Weapon.WTypes:
	set(value):
		match value:
			Weapon.WTypes.BALANCED:
				_weapon_suffix = "_b"
			Weapon.WTypes.SHORT:
				_weapon_suffix = "_t"
			Weapon.WTypes.LARGE:
				_weapon_suffix = "_s"
			_:
				_weapon_suffix = ""

@onready var _entity: Entity = _get_entity()


func _ready() -> void:
	_entity.state_changed.connect(_on_state_changed)
	_entity.weapons.weapon_changed.connect(_on_weapon_changed)
	animation_finished.connect(_on_animation_finished)
	_on_state_changed(_entity.current_state)
	_on_weapon_changed(_entity.weapons.equiped)


func _process(_delta: float) -> void:
	if _direction != _entity.look_direction_along_camera:
		_direction = _entity.look_direction_along_camera
		_set_flip()


func _on_weapon_changed(weapon: Weapon) -> void:
	_weapon_type = Weapon.WTypes.NONE if weapon == null else weapon.type


func _on_state_changed(state: Entity.EntityState) -> void:
	var anim := ""
	var should_stop := false

	match state:
		Entity.EntityState.MOVING:
			anim = _move_animation
		Entity.EntityState.IDLE:
			anim = _idle_animation
		Entity.EntityState.ATTACKING:
			anim = _attack_animation
			should_stop = true
		Entity.EntityState.HURT:
			anim = _hurt_animation
			should_stop = true
		Entity.EntityState.THROW:
			anim = _throw_animation
		Entity.EntityState.TELEPORT:
			anim = _teleport_animation
	if not has_animation(anim):
		print("Entity %s doesn't have animation %s" % [_entity.name, anim])
		return

	if should_stop:
		stop()

	play(anim)


func _on_animation_finished(_anim_name: String) -> void:
	var previous_state := _entity.current_state
	_entity.current_state = Entity.EntityState.IDLE
	if previous_state == Entity.EntityState.ATTACKING:
		print("Finished EntityState.ATTACKING animation from %s" % _entity.name)
		attack_finished.emit()


func _set_flip() -> void:
	match _direction:
		Entity.LookDirection.UP_LEFT:
			_looking_front = false
			_flip_h = false
		Entity.LookDirection.UP_RIGHT:
			_looking_front = false
			_flip_h = true
		Entity.LookDirection.DOWN_LEFT:
			_looking_front = true
			_flip_h = true
		Entity.LookDirection.DOWN_RIGHT:
			_looking_front = true
			_flip_h = false
	_on_state_changed(_entity.current_state)


func _get_entity(parent: Node = get_parent()) -> Entity:
	if parent == null:
		push_error("No s'ha trobat una Entity entre els pares de %s." % self)
		return null
	if parent is Entity:
		return parent
	return _get_entity(parent.get_parent())
