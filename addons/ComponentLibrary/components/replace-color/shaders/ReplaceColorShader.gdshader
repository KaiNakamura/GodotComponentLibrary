shader_type canvas_item;

uniform vec3 target_color;
uniform vec3 replacement_color;
uniform float tolerance;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a == 0.0) {
        discard;
    }
    vec3 color = tex_color.rgb;
    float dist = distance(color, target_color);
    if (dist < tolerance) {
        color = replacement_color;
    }
    COLOR = vec4(color, tex_color.a);
}