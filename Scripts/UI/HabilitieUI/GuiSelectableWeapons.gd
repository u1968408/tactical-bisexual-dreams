class_name GuiSelectableWeapons
extends Control

signal selected_weapon_type(type: Weapon.WTypes)

@export var selectable_weapons: Array[GuiSelectableWeaponType]

var active: bool:
	get:
		return _active
	set(value):
		_active = value
		for weapon in selectable_weapons:
			weapon.active = _active

var follow_position: Vector3

var _active: bool = false

@onready var _camera: Camera3D = get_viewport().get_camera_3d()


func _process(_delta: float) -> void:
	if not active or not _camera:
		return
	var screen_pos: Vector2 = _camera.unproject_position(follow_position)
	position = screen_pos


func _ready() -> void:
	for weapon in selectable_weapons:
		weapon.clicked.connect(_on_selected_weapon)


func _on_selected_weapon(type: Weapon.WTypes):
	selected_weapon_type.emit(type)
