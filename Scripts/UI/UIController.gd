class_name UIController
extends CanvasLayer

static var instance: UIController

@export var combat_ui: CombatUI


func _ready() -> void:
	instance = self
