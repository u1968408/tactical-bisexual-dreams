shader_type spatial;
render_mode blend_mix, unshaded;

uniform float alpha_multiplier : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    ALPHA = alpha_multiplier;
}