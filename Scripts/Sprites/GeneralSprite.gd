extends Sprite3D

const HD_PIXEL_OCCLUSION_COMPONENT := preload("uid://bjkyx1wmow4yy")
const HD_PIXEL_MATERIAL := preload("uid://175fxtajyqlu")


func _ready() -> void:
	_add_hd_pixel_occlusion_component()


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
	var environment := get_tree().get_first_node_in_group("world_environment") as WorldEnvironment

	if environment == null:
		push_error("No s'ha trobat WorldEnv en %s" % [name])
		return null

	if environment.compositor == null:
		push_error("No s'ha trobat compositor al WorldEnv en %s" % [name])
		return null

	for effect in environment.compositor.compositor_effects:
		if effect is EdgePixelCompositorEffect:
			return effect

	return null
