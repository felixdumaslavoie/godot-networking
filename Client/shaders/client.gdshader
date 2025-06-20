shader_type spatial;

uniform sampler2D tex;

void fragment() {

vec4 tex_col = texture(tex,UV);

vec3 tint = vec3(1.0,0.0,0.0);

ALBEDO = tex_col.rgb + tint;
}