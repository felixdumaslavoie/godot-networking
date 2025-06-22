shader_type canvas_item;
render_mode blend_mix;
// Expose 'my_color' to the editor with default value of gray (r, g, b, alpha).
uniform vec4 my_color : source_color = vec4(.5, .0, .5, 0.5);
// This function is run on every pixel.
void fragment(){
	// Modify COLOR to affect the results.
	// Here we just interpolate with default color and supplied color.
	COLOR = mix(COLOR, my_color, .5);
}