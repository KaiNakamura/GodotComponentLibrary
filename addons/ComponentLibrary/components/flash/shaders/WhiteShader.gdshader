shader_type canvas_item;

void fragment() {
	vec4 origin = texture(TEXTURE, UV);
	COLOR.rgb = vec3(1, 1, 1);
	COLOR.a = origin.a;
}