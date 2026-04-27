extends Node
class_name AnimationController

@export var sprite: AnimatedSprite3D

@onready var _entity: Entity = get_parent()
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_entity.state_changed.connect(_OnStateChanged)
	

func _OnStateChanged(state: Entity.EntityState):
	match state:
		Entity.EntityState.Moving:
			_current_anim = AnimationNames.MOVE
		Entity.EntityState.Idle:
			_current_anim = AnimationNames.IDLE
		Entity.EntityState.Attacking:
			_current_anim = AnimationNames.IDLE
	sprite.play(animation)

func _process(_delta: float) -> void:
	if _direction != _entity.look_direction_along_camera:
		_direction = _entity.look_direction_along_camera
		_set_flip()


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
	sprite.play(animation)
