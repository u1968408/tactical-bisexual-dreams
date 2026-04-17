extends Node
class_name Stats

const DEX_FOR_TILE: int = 20
@export var base_stats: BaseStats

signal life_damaged(damage: int, new_health: int)
signal life_gained(cure: int, new_health: int)

var _current_health: int

func _ready() -> void:
	_current_health = max_health

var morale: float:
	get:
		return base_stats.morale
	
var health: int:
	get:
		return health
	set(value):
		var new_health := clampi(health + value, 0, max_health)
		var change: int = new_health - health
		if change == 0:
			return
		health = new_health
		if change < 0:
			life_damaged.emit(change, health)
		elif change > 0:
			life_gained.emit(change, health)

var max_health: int:
	get:
		return base_stats.health

var resistance: int:
	get:
		return base_stats.resistance

var attack: int:
	get:
		return base_stats.attack

var dexterity: int:
	get:
		return base_stats.dexterity

var precision: int:
	get:
		return base_stats.precision

var movement: int:
	get:
		var mov_f: float = float(dexterity) / DEX_FOR_TILE
		return int(mov_f)