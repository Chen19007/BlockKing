shader_type canvas_item;

uniform vec4 ink_color : source_color = vec4(0.1294, 0.1098, 0.1020, 1.0);
uniform vec4 outline_color : source_color = vec4(0.96, 0.92, 0.84, 0.64);
uniform vec4 shadow_color : source_color = vec4(0.09, 0.07, 0.05, 0.48);
uniform float outline_size = 1.0;
uniform vec2 shadow_offset = vec2(1.0, 1.0);
uniform float erosion_strength : hint_range(0.0, 0.2) = 0.02;

void fragment() {
	float base_a = COLOR.a;
	if (base_a <= 0.001) {
		COLOR = vec4(0.0);
	} else {
		vec2 noise_uv = floor(UV * vec2(2048.0, 2048.0));
		float noise_v = fract(sin(dot(noise_uv, vec2(12.9898, 78.233))) * 43758.5453);
		float erosion = mix(1.0, noise_v, erosion_strength);
		COLOR = vec4(ink_color.rgb, base_a * erosion);
	}
}
