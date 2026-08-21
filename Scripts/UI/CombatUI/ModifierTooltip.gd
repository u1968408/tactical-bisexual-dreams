class_name ModifierTooltip
extends PanelContainer

@export var icon_rect: TextureRect
@export var name_label: Label
@export var type_label: Label
@export var value_label: Label


func setup(mod: Modifier) -> void:
	icon_rect.texture = mod.icon
	name_label.text = mod.modifier_name
	type_label.text = Stats.get_stat_name(mod.type)
	value_label.text = "%d" % mod.value if mod.value < 0 else "+%d" % mod.value
