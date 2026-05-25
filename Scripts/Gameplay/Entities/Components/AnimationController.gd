extends EntityNode
class_name AnimationController

signal animation_fliped(fliped: bool, direction: String)

@export var sprite: AnimatedSprite3D
@export_flags("Idle", "Attack", "Move") var avaible_animations := 0

var _direction: Entity.LookDirection

var _current_anim: String = AnimationNames.IDLE
var _current_dir: String = AnimationNames.FRONT

var animation:
	get:
		return _current_anim + _current_dir

class AnimationNames:
	const BACK: String = "_b"
	const FRONT: String = "_f"

	const IDLE: String = "idle"
	const MOVE: String = "walk"
	const ATTACK: String = "attack"

const ANIM_IDLE := 1
const ANIM_ATTACK := 2
const ANIM_MOVE := 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity.state_changed.connect(_OnStateChanged)
	sprite.animation_finished.connect(_OnAnimationfinished)

func _OnAnimationfinished() -> void:
	entity.current_state = Entity.EntityState.Idle

func _OnStateChanged(state: Entity.EntityState) -> void:
	var flag := 0
	var anim := ""

	match state:
		Entity.EntityState.Moving:
			flag = ANIM_MOVE
			anim = AnimationNames.MOVE

		Entity.EntityState.Idle:
			flag = ANIM_IDLE
			anim = AnimationNames.IDLE

		Entity.EntityState.Attacking:
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
	_OnStateChanged(entity.current_state)
