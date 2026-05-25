@tool
extends Node
class_name HDPixelOcclusionComponent

@export var base_material: ShaderMaterial
@export var auto_apply_on_ready := true
@export var duplicate_material_per_instance := true

@export_group("Shader uniforms")
@export var texture_uniform_name := "sprite_texture"
@export var pixel_size_uniform_name := "pixel_size"
@export var depth_bias_uniform_name := "depth_bias"

@export var pixel_size := 4:
	set(value):
		pixel_size = max(value, 1)
		_apply_shader_params()

@export var depth_bias := 0.001:
	set(value):
		depth_bias = max(value, 0.0)
		_apply_shader_params()

var _target: Node = null
var _runtime_material: ShaderMaterial = null


func _ready() -> void:
	if auto_apply_on_ready:
		apply_to_parent()


func apply_to_parent() -> void:
	_target = get_parent()

	if _target == null:
		push_warning("HDPixelOcclusionComponent: no parent found.")
		return

	if not (_target is Sprite3D or _target is AnimatedSprite3D):
		push_warning("HDPixelOcclusionComponent: parent must be Sprite3D or AnimatedSprite3D.")
		return

	if base_material == null:
		push_warning("HDPixelOcclusionComponent: base_material is not assigned.")
		return

	_runtime_material = base_material.duplicate() if duplicate_material_per_instance else base_material

	# Sprite3D and AnimatedSprite3D inherit from GeometryInstance3D,
	# so they expose material_override.
	_target.material_override = _runtime_material

	_connect_target_signals()
	_apply_shader_params()
	_update_texture()


func _connect_target_signals() -> void:
	if not (_target is AnimatedSprite3D):
		return

	if not _target.frame_changed.is_connected(_update_texture):
		_target.frame_changed.connect(_update_texture)

	if not _target.animation_changed.is_connected(_update_texture):
		_target.animation_changed.connect(_update_texture)

	if not _target.sprite_frames_changed.is_connected(_update_texture):
		_target.sprite_frames_changed.connect(_update_texture)


func _apply_shader_params() -> void:
	if _runtime_material == null:
		return

	_runtime_material.set_shader_parameter(pixel_size_uniform_name, pixel_size)
	_runtime_material.set_shader_parameter(depth_bias_uniform_name, depth_bias)


func _update_texture() -> void:
	if _target == null or _runtime_material == null:
		return

	var tex: Texture2D = null

	if _target is AnimatedSprite3D:
		tex = _get_animated_sprite_3d_texture(_target)
	elif _target is Sprite3D:
		tex = _get_sprite_3d_texture(_target)

	# Set even when null so stale textures are not kept accidentally.
	_runtime_material.set_shader_parameter(texture_uniform_name, tex)


func _get_animated_sprite_3d_texture(sprite: AnimatedSprite3D) -> Texture2D:
	if sprite.sprite_frames == null:
		return null

	if not sprite.sprite_frames.has_animation(sprite.animation):
		return null

	var frame_count := sprite.sprite_frames.get_frame_count(sprite.animation)
	if frame_count <= 0:
		return null

	var safe_frame := clampi(sprite.frame, 0, frame_count - 1)
	return sprite.sprite_frames.get_frame_texture(sprite.animation, safe_frame)


func _get_sprite_3d_texture(sprite: Sprite3D) -> Texture2D:
	return sprite.texture
