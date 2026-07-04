class_name Stats
extends Node

signal stats_changed
signal health_changed(change_value: int, new_health: int)

enum StatType {
	MORALE,
	DEXTERITY,
	FORCE,
	VITALITY,
	PRECISION,
	RESISTANCE,
}

const DEX_FOR_TILE: int = 2
const VIT_FOR_HP: int = 5
@export var base_stats: BaseStats

var health: int:
	get:
		return _current_health
	set(value):
		var new_health := clampi(value, 0, max_health)
		var change: int = new_health - _current_health
		if change == 0:
			return
		_current_health = new_health
		health_changed.emit(change, _current_health)

var morale: int:
	get:
		return _apply_modifiers(StatType.MORALE, base_stats.morale)

var max_health: int:
	get:
		return base_stats.vitality * 10

var resistance: int:
	get:
		return _apply_modifiers(StatType.RESISTANCE, base_stats.resistance)

var force: int:
	get:
		var base := _apply_modifiers(StatType.FORCE, base_stats.force)
		return calculate_multiplier(base, morale)

var dexterity: int:
	get:
		var base := _apply_modifiers(StatType.DEXTERITY, base_stats.dexterity)
		return calculate_multiplier(base, morale)

var precision: int:
	get:
		var base := _apply_modifiers(StatType.PRECISION, base_stats.precision)
		return calculate_multiplier(base, morale)

var movement: int:
	get:
		var mov_f: float = float(dexterity) / DEX_FOR_TILE
		return int(mov_f)

var attack_range: int:
	get:
		var wpn: Weapon = _entity.weapons.equiped
		if wpn == null:
			return 1
		return wpn.attack_range

var damage: int:
	get:
		var wpn: Weapon = _entity.weapons.equiped
		var base_damage: int = force
		if wpn != null:
			base_damage += wpn.damage
		return base_damage

var _current_health: int
var _modifiers: Array[Modifier] = []
@onready var _entity: Entity = get_parent()


func _ready() -> void:
	_current_health = max_health
	base_stats.stats_changed.connect(func(): stats_changed.emit())


static func calculate_add(base: int, modifier: int) -> int:
	return base + modifier


static func calculate_multiplier(base: int, modifier: int) -> int:
	var multiplier := get_multiplier(modifier)
	return int(base * multiplier)


static func get_multiplier(modifier: int) -> float:
	var multiplier := (50 + 5.0 * modifier) / 100
	return multiplier


static func get_stat_name(type: StatType) -> String:
	match type:
		StatType.MORALE:
			return "Moral"
		StatType.DEXTERITY:
			return "Destreza"
		StatType.FORCE:
			return "Fuerza"
		StatType.VITALITY:
			return "Vitalidad"
		StatType.PRECISION:
			return "Presición"
		StatType.RESISTANCE:
			return "Resistencia"
	return ""


func get_stat_value(type: StatType) -> int:
	match type:
		StatType.MORALE:
			return morale
		StatType.DEXTERITY:
			return dexterity
		StatType.FORCE:
			return force
		StatType.PRECISION:
			return precision
		StatType.RESISTANCE:
			return resistance
	# StatType.VITALITY
	return base_stats.vitality


func add_modifier(modifier: Modifier) -> void:
	_modifiers.append(modifier)
	stats_changed.emit()


func delete_modifier(modifier: Modifier) -> void:
	var idx := _modifiers.find(modifier)
	if idx >= 0:
		_modifiers.remove_at(idx)
	stats_changed.emit()


func _get_modifiers_of_type(type: StatType) -> Array[Modifier]:
	return _modifiers.filter(func(mod: Modifier): return mod.type == type)


func _apply_modifiers(type: StatType, base_value: int) -> int:
	if type == StatType.VITALITY:
		push_error("vitality should not be recalculated.")
		return base_value
	var mods := _get_modifiers_of_type(type)
	return mods.reduce(func(accum: int, mod: Modifier): return accum + mod.value, base_value)
