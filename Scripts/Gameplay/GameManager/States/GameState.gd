@abstract class_name GameState
extends State

var entities: Array[Entity]:
	get:
		var group: Array[Node] = get_tree().get_nodes_in_group("Entity")
		var ents: Array[Entity] = []
		for node in group:
			if node is Entity:
				ents.append(node)
		return ents

var characters: Array[Character]:
	get:
		var chars: Array[Character] = []
		for node in entities:
			if node is Character:
				chars.append(node)
		return chars

var enemies: Array[Enemy]:
	get:
		var enms: Array[Enemy] = []
		for node in entities:
			if node is Enemy:
				enms.append(node)
		return enms

var ui_controller: UIController:
	get:
		return UIController.instance

var player_ui: PlayerUI:
	get:
		return ui_controller.player_ui

@onready var camera: CameraController = get_viewport().get_camera_3d()

@onready var game_manager: GameManager = get_parent().get_parent()
