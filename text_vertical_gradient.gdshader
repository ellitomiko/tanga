shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.470588, 0.392157, 0.800000, 1.0); // #7864CC
uniform vec4 bottom_color : source_color = vec4(0.650980, 0.560784, 1.000000, 1.0); // #A68FFF

uniform float gradient_start_y = 0.0;
uniform float gradient_height = 61.0;

varying vec2 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	vec4 text_pixel = texture(TEXTURE, UV) * COLOR;
	
	float gradient_position = clamp(
		(local_position.y - gradient_start_y) / gradient_height,
		0.0,
		1.0
	);
	
	vec3 gradient_color = mix(
		top_color.rgb,
		bottom_color.rgb,
		gradient_position
	);
	
	COLOR = vec4(gradient_color, text_pixel.a);
}