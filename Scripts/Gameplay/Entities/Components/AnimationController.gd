class_name AnimationController
extends EntityNode

signal animation_fliped(fliped: bool, direction: String)

const ANIM_IDLE := 1
const ANIM_ATTACK := 2
const ANIM_MOVE := 4

@export var sprite: AnimatedSprite3D
@export_flags("Idle", "Attack", "Move") var avaible_animations := 0

var animation:
	get:
		return _current_anim + _current_dir

var _direction: Entity.LookDirection

var _current_anim: String = AnimationNames.IDLE
var _current_dir: String = AnimationNames.FRONT


class AnimationNames:
	const BACK: String = "_b"
	const FRONT: String = "_f"

	const IDLE: String = "idle"
	const MOVE: String = "walk"
	const ATTACK: String = "attack"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity.state_changed.connect(_on_state_changed)
	sprite.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	entity.current_state = Entity.EntityState.IDLE


func _on_state_changed(state: Entity.EntityState) -> void:
	var flag := 0
	var anim := ""

	match state:
		Entity.EntityState.MOVING:
			flag = ANIM_MOVE
			anim = AnimationNames.MOVE

		Entity.EntityState.IDLE:
			flag = ANIM_IDLE
			anim = AnimationNames.IDLE

		Entity.EntityState.ATTACKING:
			flag = ANIM_ATTACK
			anim = AnimationNames.ATTACK

	if not _has_animation_flag(flag):
		return

	_current_anim = anim
	if sprite.sprite_frames != null:
		sprite.play(animation)


func _process(_delta: float) -> void:
	if _direction != entity.look_direction_along_camera:
		_direction = entity.look_direction_along_camera
		_set_flip()


func _has_animation_flag(flag: int) -> bool:
	return (avaible_animations & flag) != 0


func _set_flip() -> void:
	match _direction:
		Entity.LookDirection.UP_LEFT:
			_current_dir = AnimationNames.BACK
			sprite.flip_h = false
		Entity.LookDirection.UP_RIGHT:
			_current_dir = AnimationNames.BACK
			sprite.flip_h = true
		Entity.LookDirection.DOWN_LEFT:
			_current_dir = AnimationNames.FRONT
			sprite.flip_h = true
		Entity.LookDirection.DOWN_RIGHT:
			_current_dir = AnimationNames.FRONT
			sprite.flip_h = false
	animation_fliped.emit(sprite.flip_h, _current_dir)
	_on_state_changed(entity.current_state)
