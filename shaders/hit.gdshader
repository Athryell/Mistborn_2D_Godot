shader_type canvas_item;

uniform float white_amount : hint_range(0.0, 1.0) = 0.0;
uniform float wave_amount: hint_range(-50.0, 50.0, 0.1) = 0.0;

void vertex() {
	if (VERTEX.y < 0.0){
		VERTEX.x += UV.y * wave_amount;
	}
	
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, vec3(1), white_amount);
	COLOR = color;
}

