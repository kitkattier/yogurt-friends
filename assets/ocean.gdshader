shader_type canvas_item;

uniform sampler2D ocean_texture : repeat_enable;
uniform float speed = 0.5;

void fragment() {
    vec2 uv = UV * 40.0;
    uv.x += TIME * speed;
    COLOR = texture(ocean_texture, uv);
}