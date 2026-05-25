#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// 32 floats sent from GDScript.
layout(set = 0, binding = 0, std430) restrict readonly buffer Params {
	float data[];
} params;

layout(rgba16f, set = 0, binding = 1) uniform image2D color_image;

layout(set = 0, binding = 2) uniform sampler2D depth_texture;
layout(set = 0, binding = 3) uniform sampler2D normal_roughness_texture;


vec2 get_size() {
	return vec2(params.data[0], params.data[1]);
}

float get_pixel_size() {
	return max(params.data[2], 1.0);
}

bool pixelization_enabled() {
	return params.data[4] > 0.5;
}

bool depth_edges_enabled() {
	return params.data[5] > 0.5;
}

bool normal_edges_enabled() {
	return params.data[6] > 0.5;
}

bool cel_shading_enabled() {
	return params.data[7] > 0.5;
}

float get_shadow_strength() {
	return params.data[8];
}

float get_highlight_strength() {
	return params.data[9];
}

float get_depth_edge_threshold() {
	return clamp(params.data[10], 0.0, 1.0);
}

float get_depth_edge_scale() {
	return max(params.data[20], 1.0);
}

float get_normal_edge_threshold() {
	return params.data[11];
}

float get_cel_bands() {
	return max(params.data[21], 2.0);
}

float get_cel_strength() {
	return clamp(params.data[22], 0.0, 1.0);
}

vec3 get_shadow_color() {
	return vec3(params.data[12], params.data[13], params.data[14]);
}

vec3 get_highlight_color() {
	return vec3(params.data[16], params.data[17], params.data[18]);
}

ivec2 clamp_pixel(ivec2 p, ivec2 size) {
	return clamp(p, ivec2(0), size - ivec2(1));
}

ivec2 pixelize_pixel(ivec2 p, ivec2 size) {
	if (!pixelization_enabled()) {
		return clamp_pixel(p, size);
	}

	int ps = int(get_pixel_size());
	ivec2 block = p / ps;
	ivec2 center = block * ps + ivec2(ps / 2);

	return clamp_pixel(center, size);
}

vec2 pixel_to_uv(ivec2 p, ivec2 size) {
	return (vec2(p) + vec2(0.5)) / vec2(size);
}

float get_depth_at(ivec2 p, ivec2 size) {
	vec2 uv = pixel_to_uv(clamp_pixel(p, size), size);
	return texture(depth_texture, uv).r;
}

float scaled_depth_diff(float a, float b) {
	return abs(a - b) * get_depth_edge_scale();
}

vec3 get_normal_at(ivec2 p, ivec2 size) {
	vec2 uv = pixel_to_uv(clamp_pixel(p, size), size);
	vec3 n = texture(normal_roughness_texture, uv).xyz * 2.0 - 1.0;

	float len_n = length(n);
	if (len_n > 0.00001) {
		n /= len_n;
	}

	return n;
}

float smooth_edge(float threshold, float value) {
	float softness = 0.025;
	return smoothstep(threshold, threshold + softness, value);
}

vec3 apply_cel_shading(vec3 color) {
	if (!cel_shading_enabled()) {
		return color;
	}

	float bands = get_cel_bands();
	float luminance = clamp(dot(color, vec3(0.2126, 0.7152, 0.0722)), 0.0, 1.0);

	// Quantize to the center of each band instead of the lower edge.
	// This avoids crushing most of the image darker when cel shading is enabled.
	float band_index = floor(luminance * bands);
	band_index = min(band_index, bands - 1.0);
	float quantized_luminance = (band_index + 0.5) / bands;

	float safe_luminance = max(luminance, 0.001);
	vec3 cel_color = color * (quantized_luminance / safe_luminance);
	cel_color = clamp(cel_color, 0.0, 1.0);

	return mix(color, cel_color, get_cel_strength());
}

// Reversed-Z raw depth:
// larger depth value = closer to camera.
// near_edge is the inside/foreground side of a depth jump.
// far_edge is the outside/background side, mainly used to suppress normal highlights.
void compute_depth_edges(
	ivec2 p,
	ivec2 size,
	int step_size,
	out float near_edge,
	out float far_edge
) {
	near_edge = 0.0;
	far_edge = 0.0;

	if (!depth_edges_enabled() && !normal_edges_enabled()) {
		return;
	}

	float d = get_depth_at(p, size);

	float du = get_depth_at(p + ivec2(0, -step_size), size);
	float dd = get_depth_at(p + ivec2(0,  step_size), size);
	float dl = get_depth_at(p + ivec2(-step_size, 0), size);
	float dr = get_depth_at(p + ivec2( step_size, 0), size);

	float near_diff = 0.0;
	float far_diff = 0.0;

	// Godot Forward+ uses reversed-Z raw depth:
	// larger value = closer to camera.
	// For orthographic cameras, absolute raw-depth differences are more predictable
	// than relative/log-depth differences, as long as they are scaled into a usable range.
	if (d > du) {
		near_diff = max(near_diff, scaled_depth_diff(d, du));
	} else {
		far_diff = max(far_diff, scaled_depth_diff(d, du));
	}

	if (d > dd) {
		near_diff = max(near_diff, scaled_depth_diff(d, dd));
	} else {
		far_diff = max(far_diff, scaled_depth_diff(d, dd));
	}

	if (d > dl) {
		near_diff = max(near_diff, scaled_depth_diff(d, dl));
	} else {
		far_diff = max(far_diff, scaled_depth_diff(d, dl));
	}

	if (d > dr) {
		near_diff = max(near_diff, scaled_depth_diff(d, dr));
	} else {
		far_diff = max(far_diff, scaled_depth_diff(d, dr));
	}

	float threshold = get_depth_edge_threshold();
	near_edge = smooth_edge(threshold, near_diff);
	far_edge = smooth_edge(threshold, far_diff);
}

float compute_normal_highlight_edge(
	ivec2 p,
	ivec2 size,
	int step_size,
	float far_depth_edge
) {
	if (!normal_edges_enabled()) {
		return 0.0;
	}

	vec3 n = get_normal_at(p, size);

	vec3 nu = get_normal_at(p + ivec2(0, -step_size), size);
	vec3 nd = get_normal_at(p + ivec2(0,  step_size), size);
	vec3 nl = get_normal_at(p + ivec2(-step_size, 0), size);
	vec3 nr = get_normal_at(p + ivec2( step_size, 0), size);

	float normal_diff = 0.0;
	normal_diff += 1.0 - clamp(dot(n, nu), -1.0, 1.0);
	normal_diff += 1.0 - clamp(dot(n, nd), -1.0, 1.0);
	normal_diff += 1.0 - clamp(dot(n, nl), -1.0, 1.0);
	normal_diff += 1.0 - clamp(dot(n, nr), -1.0, 1.0);

	float normal_edge = smooth_edge(get_normal_edge_threshold(), normal_diff);

	// Avoid painting highlights on the background side of depth silhouettes.
	return clamp(normal_edge - far_depth_edge, 0.0, 1.0);
}

void main() {
	ivec2 p = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(get_size());

	if (p.x >= size.x || p.y >= size.y) {
		return;
	}

	ivec2 sample_p = pixelize_pixel(p, size);
	vec4 source_color = imageLoad(color_image, sample_p);

	int edge_step = pixelization_enabled() ? int(get_pixel_size()) : 1;

	float depth_edge = 0.0;
	float far_depth_edge = 0.0;
	compute_depth_edges(sample_p, size, edge_step, depth_edge, far_depth_edge);

	float normal_edge = compute_normal_highlight_edge(
		sample_p,
		size,
		edge_step,
		far_depth_edge
	);

	vec3 base_color = source_color.rgb;
	vec3 final_color = apply_cel_shading(base_color);

	if (normal_edges_enabled()) {
		vec3 final_highlight = mix(
			final_color,
			get_highlight_color(),
			get_highlight_strength()
		);

		final_color = mix(final_color, final_highlight, normal_edge);
	}

	if (depth_edges_enabled()) {
		vec3 final_shadow = mix(
			final_color,
			get_shadow_color(),
			get_shadow_strength()
		);

		final_color = mix(final_color, final_shadow, depth_edge);
	}

	imageStore(color_image, p, vec4(final_color, source_color.a));
}
