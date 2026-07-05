class_name Character
extends Entity

signal hability_finished

@export var character_data: SelectableCharacterData
@export var habilities: HabilityHandler


func trigger_hability_finished():
	hability_finished.emit()
