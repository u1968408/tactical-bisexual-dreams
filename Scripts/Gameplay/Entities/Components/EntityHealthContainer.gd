class_name CharacterHealthContainer
extends Control

@export var health_label: Label
@export var health_bar: TextureProgressBar
@export var health_position: Node3D
@export var entity: Entity

var _health: int:
	set(value):
		print("setting health to %s" % value)
		health_bar.value = value
		health_label.text = str(value)

var _max_health: int:
	set(value):
		health_bar.max_value = value

@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
	await entity.ready
	_max_health = entity.stats.max_health
	_set_current_health(0, entity.stats.health)
	entity.stats.health_changed.connect(_set_current_health)


func _process(_delta: float) -> void:
	if not visible:
		return
	var screen_pos := camera.unproject_position(health_position.global_position)
	global_position = screen_pos
	global_position += Vector2(-get_rect().size.x / 2, 0)


func _set_current_health(_change_value: int, new_health: int):
	_health = new_health
