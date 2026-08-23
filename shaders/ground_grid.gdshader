shader_type spatial;

uniform vec3 floor_color : source_color = vec3(0.28, 0.32, 0.30);
uniform vec3 line_color : source_color = vec3(0.72, 0.76, 0.70);
uniform vec3 major_line_color : source_color = vec3(0.92, 0.94, 0.90);
uniform float cell_size = 1.0;
uniform float major_every = 10.0;
uniform float line_width = 1.5;
uniform float major_line_width = 2.5;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 coord = world_pos.xz / cell_size;
	vec2 grid = abs(fract(coord - 0.5) - 0.5) / fwidth(coord);
	float minor_line = 1.0 - min(min(grid.x / line_width, grid.y / line_width), 1.0);

	vec2 major_coord = world_pos.xz / (cell_size * major_every);
	vec2 major_grid = abs(fract(major_coord - 0.5) - 0.5) / fwidth(major_coord);
	float major_line = 1.0 - min(min(major_grid.x / major_line_width, major_grid.y / major_line_width), 1.0);

	vec3 color = mix(floor_color, line_color, minor_line);
	color = mix(color, major_line_color, major_line);
	ALBEDO = color;
}
