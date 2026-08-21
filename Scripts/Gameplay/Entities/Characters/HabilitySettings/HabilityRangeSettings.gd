@tool
class_name HabilityRangeSettings
extends HabilitySettings

@export var hability_range: int = 1

@export var apply_modifier := false
@export var range_modifier: Stats.StatType

@export var distance_type: Generator.DistanceType
@export var create_tiles_on_solid: bool = true
@export var show_disabled_tiles: bool = false
@export_flags_3d_physics var collide_with: int = 0

var total_range:
	get:
		if apply_modifier:
			var mod: int = Stats.calculate_multiplier(10, range_modifier)
			print("calculated: %s" % mod)
			return hability_range + mod
		return hability_range
