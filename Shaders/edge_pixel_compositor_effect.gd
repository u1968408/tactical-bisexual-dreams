@tool
class_name EdgePixelCompositorEffect
extends CompositorEffect

const SHADER_PATH := "uid://by7pl7em1cpbj"
const WORKGROUP_SIZE := 8
const PARAM_FLOAT_COUNT := 32

@export_range(1, 64, 1) var pixel_size: int = 4
@export var pixelization_enabled: bool = true
@export var depth_edges_enabled: bool = true
@export var normal_edges_enabled: bool = true
@export var cel_shading_enabled: bool = false

@export_range(0.0, 1.0, 0.01) var shadow_strength: float = 0.65
@export_range(0.0, 1.0, 0.01) var highlight_strength: float = 0.25

# Screen-space cel shading. It quantizes scene luminance while preserving hue.
@export_range(2, 16, 1) var cel_bands: int = 4
@export_range(0.0, 1.0, 0.01) var cel_strength: float = 0.85

@export_color_no_alpha var shadow_color: Color = Color.BLACK
@export_color_no_alpha var highlight_color: Color = Color.WHITE

# Orthographic-friendly depth edge controls.
# depth_edge_threshold controls how much scaled depth difference is required.
# depth_edge_scale converts raw orthographic depth differences into an artist-friendly range.
@export_range(0.0, 1.0, 0.001) var depth_edge_threshold: float = 0.10
@export_range(1.0, 10000.0, 1.0) var depth_edge_scale: float = 100.0
@export_range(0.001, 2.0, 0.001) var normal_edge_threshold: float = 0.35

var rd: RenderingDevice
var shader: RID
var pipeline: RID
var sampler: RID
var parameter_buffer: RID


func _init() -> void:
	# The effect runs before transparent objects, so transparent Sprite3D nodes
	# with the HD occlusion shader are drawn after this pass.
	effect_callback_type = EFFECT_CALLBACK_TYPE_PRE_TRANSPARENT

	# Required to read forward_clustered/normal_roughness in Forward+.
	needs_normal_roughness = true

	rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		RenderingServer.call_on_render_thread(_free_compute_resources)


func _initialize_compute() -> void:
	rd = RenderingServer.get_rendering_device()
	if rd == null:
		return

	var shader_file := load(SHADER_PATH)
	if shader_file == null:
		push_error("Could not load shader: %s" % SHADER_PATH)
		return

	var spirv: RDShaderSPIRV = shader_file.get_spirv()
	if spirv == null:
		push_error("Could not get SPIR-V from shader: %s" % SHADER_PATH)
		return

	shader = rd.shader_create_from_spirv(spirv)
	if not shader.is_valid():
		push_error("Could not create shader RID.")
		return

	pipeline = rd.compute_pipeline_create(shader)
	if not pipeline.is_valid():
		push_error("Could not create compute pipeline.")
		return

	var sampler_state := RDSamplerState.new()
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.mip_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler = rd.sampler_create(sampler_state)

	var initial_params := PackedFloat32Array()
	initial_params.resize(PARAM_FLOAT_COUNT)
	initial_params.fill(0.0)

	var bytes := initial_params.to_byte_array()
	parameter_buffer = rd.storage_buffer_create(bytes.size(), bytes)


func _free_compute_resources() -> void:
	if rd == null:
		return

	if pipeline.is_valid():
		rd.free_rid(pipeline)
		pipeline = RID()

	if shader.is_valid():
		rd.free_rid(shader)
		shader = RID()

	if sampler.is_valid():
		rd.free_rid(sampler)
		sampler = RID()

	if parameter_buffer.is_valid():
		rd.free_rid(parameter_buffer)
		parameter_buffer = RID()


func _render_callback(p_callback_type: EffectCallbackType, p_render_data: RenderData) -> void:
	if rd == null:
		return

	if p_callback_type != effect_callback_type:
		return

	if not pipeline.is_valid() or not parameter_buffer.is_valid() or not sampler.is_valid():
		return

	if not pixelization_enabled and not depth_edges_enabled and not normal_edges_enabled and not cel_shading_enabled:
		return

	var render_scene_buffers := p_render_data.get_render_scene_buffers()
	if render_scene_buffers == null:
		return

	var size: Vector2i = render_scene_buffers.get_internal_size()
	if size.x <= 0 or size.y <= 0:
		return

	var view_count: int = render_scene_buffers.get_view_count()
	if view_count <= 0:
		return

	var normal_texture: RID = render_scene_buffers.get_texture(
		"forward_clustered",
		"normal_roughness"
	)
	var effective_normal_edges_enabled := normal_edges_enabled and normal_texture.is_valid()

	if not pixelization_enabled and not depth_edges_enabled and not effective_normal_edges_enabled and not cel_shading_enabled:
		return

	_update_parameter_buffer(size, effective_normal_edges_enabled)

	var uniform_params := RDUniform.new()
	uniform_params.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform_params.binding = 0
	uniform_params.add_id(parameter_buffer)

	var x_groups: int = int(ceil(float(size.x) / float(WORKGROUP_SIZE)))
	var y_groups: int = int(ceil(float(size.y) / float(WORKGROUP_SIZE)))

	for view in view_count:
		var color_image: RID = render_scene_buffers.get_color_layer(view)
		var depth_texture: RID = render_scene_buffers.get_depth_layer(view)

		if not color_image.is_valid() or not depth_texture.is_valid():
			continue

		var uniform_color := RDUniform.new()
		uniform_color.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform_color.binding = 1
		uniform_color.add_id(color_image)

		var uniform_depth := RDUniform.new()
		uniform_depth.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		uniform_depth.binding = 2
		uniform_depth.add_id(sampler)
		uniform_depth.add_id(depth_texture)

		var uniform_normal := RDUniform.new()
		uniform_normal.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		uniform_normal.binding = 3
		uniform_normal.add_id(sampler)
		uniform_normal.add_id(normal_texture if normal_texture.is_valid() else depth_texture)

		var uniforms: Array[RDUniform] = [
			uniform_params,
			uniform_color,
			uniform_depth,
			uniform_normal,
		]

		var uniform_set := UniformSetCacheRD.get_cache(shader, 0, uniforms)

		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()


func _update_parameter_buffer(size: Vector2i, effective_normal_edges_enabled: bool) -> void:
	var params := PackedFloat32Array()
	params.resize(PARAM_FLOAT_COUNT)
	params.fill(0.0)

	# params[0..3]
	params[0] = float(size.x)
	params[1] = float(size.y)
	params[2] = float(max(pixel_size, 1))
	params[3] = 0.0

	# params[4..7]
	params[4] = 1.0 if pixelization_enabled else 0.0
	params[5] = 1.0 if depth_edges_enabled else 0.0
	params[6] = 1.0 if effective_normal_edges_enabled else 0.0
	params[7] = 1.0 if cel_shading_enabled else 0.0

	# params[8..11]
	params[8] = shadow_strength
	params[9] = highlight_strength
	params[10] = depth_edge_threshold
	params[11] = normal_edge_threshold

	# params[12..15]
	params[12] = shadow_color.r
	params[13] = shadow_color.g
	params[14] = shadow_color.b
	params[15] = 0.0

	# params[16..19]
	params[16] = highlight_color.r
	params[17] = highlight_color.g
	params[18] = highlight_color.b
	params[19] = 0.0

	# params[20..23]
	params[20] = depth_edge_scale
	params[21] = float(max(cel_bands, 2))
	params[22] = cel_strength
	params[23] = 0.0

	var bytes := params.to_byte_array()
	rd.buffer_update(parameter_buffer, 0, bytes.size(), bytes)
