extends AnimatedSprite3D

const HD_PIXEL_OCCLUSION_COMPONENT := preload("uid://bjkyx1wmow4yy")
const HD_PIXEL_MATERIAL := preload("uid://175fxtajyqlu")

@onready var _camera: Camera3D = get_viewport().get_camera_3d()


func _ready() -> void:
	_add_hd_pixel_occlusion_component()


func _process(_delta: float) -> void:
	if _camera == null:
		_camera = get_viewport().get_camera_3d()
		if _camera == null:
			return

	look_at(_camera.global_position, Vector3.UP, true)


func _add_hd_pixel_occlusion_component() -> void:
	if has_node("HDPixelOcclusionComponent"):
		return

	var component: Node = HD_PIXEL_OCCLUSION_COMPONENT.new()
	component.name = "HDPixelOcclusionComponent"

	component.base_material = HD_PIXEL_MATERIAL
	component.auto_apply_on_ready = true
	component.duplicate_material_per_instance = true

	add_child(component)

	_apply_environment_values_to_component(component)


func _apply_environment_values_to_component(component: Node) -> void:
	var effect := _get_edge_pixel_compositor_effect()
	if effect == null:
		return

	if "pixel_size" in effect:
		component.pixel_size = effect.pixel_size

	if "sprite_depth_bias" in effect:
		component.depth_bias = effect.sprite_depth_bias
	elif "depth_bias" in effect:
		component.depth_bias = effect.depth_bias
	else:
		component.depth_bias = 0.001

func _get_edge_pixel_compositor_effect() -> Object:
	var environment := %WorldEnvironment
	if environment == null:
		return null

	if environment.compositor == null:
		return null

	for effect in environment.compositor.compositor_effects:
		if effect is EdgePixelCompositorEffect:
			return effect

	return null
