class_name CombatUtils

enum Actions {
	NONE = 0,
	MOVE = 1,
	ATTACK = 2,
	HABILITIES = 3,
}

const POSSIBLE_STATES: Array[CombatUtils.Actions] = [
	CombatUtils.Actions.HABILITIES,
	CombatUtils.Actions.ATTACK,
	CombatUtils.Actions.MOVE
]