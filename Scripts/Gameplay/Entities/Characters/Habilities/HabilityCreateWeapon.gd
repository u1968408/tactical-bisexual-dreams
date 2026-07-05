extends Hability

@export var weapons_ui: GuiSelectableWeapons

var _current_destroyable: DestroyableObject


func _ready() -> void:
	weapons_ui.active = false
	weapons_ui.selected_weapon_type.connect(_on_selected_weapon_type)


func _execute() -> void:
	print("Executing %s Hability" % settings.hability_name)


func clicked_tile(tile: Tile):
	generator = null
	_current_destroyable = tile.destroyable_object
	if _current_destroyable == null or _current_destroyable.destroyed:
		finished.emit(false)
		return
	weapons_ui.follow_position = tile.global_position
	weapons_ui.active = true


func _on_selected_weapon_type(type: Weapon.WTypes):
	_current_destroyable.destroyed = true
	var new_weapon = WeaponLibrary.get_weapon(type, _current_destroyable.material_type)
	character.weapons.equiped = new_weapon
	_current_destroyable = null
	weapons_ui.active = false
	finished.emit(true)
