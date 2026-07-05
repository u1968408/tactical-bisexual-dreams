class_name GuiWeaponDescription
extends Control

@export var weapon_name: Label
@export var container: VBoxContainer
@export var font_settings_desc: LabelSettings

var active: bool:
	get:
		return _active

var _active: bool = false


func assign_weapon(weapon: Weapon):
	_reset()
	if weapon == null:
		_active = false
		return
	_active = true
	weapon_name.text = weapon.name
	_create_row("Daño", str(weapon.damage))
	_create_row("Rango", str(weapon.attack_range))
	if weapon.modifiers.is_empty():
		return
	_create_row("MODIFICADORES", "")
	for mod in weapon.modifiers:
		_create_row("  " + Stats.get_stat_name(mod.type), str(mod.value))


func _reset():
	for n in container.get_children():
		container.remove_child(n)
		n.queue_free()


func _create_row(title: String, text: String):
	var cont_h := HBoxContainer.new()
	var label_title := Label.new()
	label_title.label_settings = font_settings_desc
	label_title.size_flags_horizontal = Control.SIZE_EXPAND
	label_title.text = title
	var label_text := Label.new()
	label_text.label_settings = font_settings_desc
	label_text.text = text
	cont_h.add_child(label_title)
	cont_h.add_child(label_text)
	container.add_child(cont_h)
