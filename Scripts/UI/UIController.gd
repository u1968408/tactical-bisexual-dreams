class_name UIController
extends CanvasLayer

static var instance: UIController

@export var combat_ui: CombatUI
@export var player_ui: PlayerUI


func _init() -> void:
	instance = self
