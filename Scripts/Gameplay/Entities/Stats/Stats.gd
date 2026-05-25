extends Node
class_name Stats

const DEX_FOR_TILE: int = 2
const VIT_FOR_HP: int = 5
@export var base_stats: BaseStats
@onready var _entity: Entity = get_parent()

signal life_damaged(damage: int, new_health: int)
signal life_gained(cure: int, new_health: int)

enum StatType {
	Morale,
	Dexterity,
	Force,
	Vitality,
	Precision,
	Resistance,
}

var _current_health: int
var _modifiers: Array[Modifier] = []


func _ready() -> void:
	_current_health = max_health
	var mod := Modifier.new(StatType.Dexterity, 50)
	_modifiers.append(mod)

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

var morale: int:
	get:
		return _ApplyModifiers(
			StatType.Morale,
			base_stats.morale
		)

var max_health: int:
	get:
		return base_stats.vitality * 10

var resistance: int:
	get:
		return _ApplyModifiers(
			StatType.Resistance,
			base_stats.resistance
		)

var force: int:
	get:
		var base := _ApplyModifiers(
			StatType.Force,
			base_stats.force
		)
		return CalculateMultiplier(base, morale)

var dexterity: int:
	get:
		var base := _ApplyModifiers(
			StatType.Dexterity,
			base_stats.dexterity
		)
		return CalculateMultiplier(base, morale)

var precision: int:
	get:
		var base := _ApplyModifiers(
			StatType.Precision,
			base_stats.precision
		)
		return CalculateMultiplier(base, morale)

var movement: int:
	get:
		var mov_f: float = float(dexterity) / DEX_FOR_TILE
		return int(mov_f)

var attack_range: int:
	get:
		var wpn : Weapon = _entity.weapons.equiped
		if wpn == null:
			return 1
		return wpn.attack_range

var damage: int:
	get:
		var wpn : Weapon = _entity.weapons.equiped
		var base_damage: int = force
		if wpn != null:
			base_damage += wpn.damage
		return base_damage

static func CalculateAdd(base: int, modifier: int) -> int:
	return base + modifier

static func CalculateMultiplier(base: int, modifier: int) -> int:
	var multiplier := GetMultiplier(modifier)
	return int(base * multiplier)

static func GetMultiplier(modifier: int) -> float:
	var multiplier := (50 + 5.0 * modifier) / 100
	return multiplier

func AddModifier(modifier: Modifier) -> void:
	_modifiers.append(modifier)

func DeleteModifier(modifier: Modifier) -> void:
	var idx := _modifiers.find(modifier)
	if idx >= 0:
		_modifiers.remove_at(idx)

func _GetModifiersOfType(type: StatType) -> Array[Modifier]:
	return _modifiers.filter(
		func (mod: Modifier): return mod.type == type
	)

func _ApplyModifiers(type: StatType, base_value: int) -> int:
	if type == StatType.Vitality:
		push_error("vitality should not be recalculated.")
		return base_value
	var mods := _GetModifiersOfType(type)
	return mods.reduce(
		func (accum: int, mod: Modifier):
			return accum + mod.value,
		base_value
	)
