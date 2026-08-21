class_name ModifierContainer
extends ColorRect

@export var icon: TextureRect
@export var tooltip_scene: PackedScene

var current_modifier: Modifier:
    get:
        return _current_modifier
    set(value):
        _current_modifier = value
        if _current_modifier != null:
            icon.texture = _current_modifier.icon

var _current_modifier: Modifier
var _tooltip_instance: ModifierTooltip


func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
    if _tooltip_instance != null and _tooltip_instance.visible:
        var offset_x := _tooltip_instance.size.x + 10.0
        _tooltip_instance.global_position = get_global_mouse_position() + Vector2(-offset_x, 10.0)


func _on_mouse_entered() -> void:
    if _current_modifier == null or tooltip_scene == null:
        return

    if _tooltip_instance == null:
        _tooltip_instance = tooltip_scene.instantiate() as ModifierTooltip
        _tooltip_instance.top_level = true
        add_child(_tooltip_instance)

    _tooltip_instance.setup(_current_modifier)
    _tooltip_instance.reset_size()
    _tooltip_instance.show()


func _on_mouse_exited() -> void:
    if _tooltip_instance != null:
        _tooltip_instance.hide()