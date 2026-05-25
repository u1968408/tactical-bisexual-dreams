shader_type spatial;

render_mode
	unshaded,
	blend_mix,
	depth_draw_never,
	depth_test_disabled,
	cull_disabled,
	fog_disabled,
	shadows_disabled;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_nearest;

uniform int pixel_size : hint_range(1, 64, 1) = 4;
uniform float alpha_cutoff : hint_range(0.0, 1.0, 0.01) = 0.01;
uniform float depth_bias : hint_range(0.0, 1.0, 0.001) = 0.001;

uniform int debug_mode : hint_range(0, 3, 1) = 0;

vec2 get_pixelized_screen_uv(vec2 uv) {
	vec2 viewport_size = vec2(textureSize(DEPTH_TEXTURE, 0));
	float safe_pixel_size = max(float(pixel_size), 1.0);
	vec2 pixel_count = max(viewport_size / safe_pixel_size, vec2(1.0));

	return (floor(uv * pixel_count) + vec2(0.5)) / pixel_count;
}

float linearize_depth(float raw_depth, vec2 screen_uv, mat4 inv_projection_matrix) {
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, raw_depth);
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;

	return -view.z;
}

void fragment() {
	vec4 tex = texture(sprite_texture, UV);

	if (tex.a <= alpha_cutoff) {
		discard;
	}

	vec2 pixel_uv = get_pixelized_screen_uv(SCREEN_UV);

	float scene_raw_depth = texture(DEPTH_TEXTURE, pixel_uv).r;
	float sprite_raw_depth = FRAGCOORD.z;

	float scene_depth = linearize_depth(scene_raw_depth, pixel_uv, INV_PROJECTION_MATRIX);
	float sprite_depth = linearize_depth(sprite_raw_depth, SCREEN_UV, INV_PROJECTION_MATRIX);

	bool occluded = sprite_depth > scene_depth + depth_bias;

	if (debug_mode == 1) {
		ALBEDO = vec3(scene_depth * 0.05);
		ALPHA = 1.0;
	} else if (debug_mode == 2) {
		ALBEDO = vec3(sprite_depth * 0.05);
		ALPHA = 1.0;
	} else if (debug_mode == 3) {
		ALBEDO = occluded ? vec3(1.0, 0.0, 0.0) : vec3(1.0);
		ALPHA = 1.0;
	} else {
		if (occluded) {
			discard;
		}

		ALBEDO = tex.rgb;
		ALPHA = tex.a;
	}
}
