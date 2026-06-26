class_name GuiDancingLabel
extends RichTextLabel

const _EFFECT: String = "[tornado radius=5 freq=2]"
var _original_text: String


func _ready() -> void:
	bbcode_enabled = true
	_original_text = text


func set_new_text(new_text: String) -> void:
	_original_text = new_text
	text = _original_text


func dance():
	text = _EFFECT + _original_text


func stop():
	text = _original_text


func inverted_color():
	add_theme_color_override("default_color", Color.WHITE)


func default_color():
	remove_theme_color_override("default_color")
