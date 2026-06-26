class_name Weapons
extends Node3D

signal weapon_changed(weapon: Weapon)

@export var equiped: Weapon:
	get:
		return _equiped
	set(value):
		_equiped = value
		weapon_changed.emit(value)

var _equiped: Weapon
