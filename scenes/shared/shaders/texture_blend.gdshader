shader_type canvas_item;

uniform sampler2D texture_1;
uniform sampler2D texture_2;
uniform float mix_value: hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() {
	vec4 in_tex_1 = texture(texture_1, UV);
	vec4 in_tex_2 = texture(texture_2, UV);
	COLOR = mix(in_tex_1, in_tex_2, mix_value);
}
