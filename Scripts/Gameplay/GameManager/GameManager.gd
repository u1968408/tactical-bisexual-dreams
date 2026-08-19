class_name GameManager
extends Node

@export var state_machine: StateMachine

@export var initial_state: State

@export var player_controller: PlayerController

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


static func get_current(caller_node: Node) -> GameManager:
	var nodes := caller_node.get_tree().get_nodes_in_group("game_manager")
	for node in nodes:
		if node is GameManager:
			return node as GameManager
	return null


func _ready() -> void:
	start_round()


func start_round() -> void:
	state_machine.set_current_state(initial_state)
