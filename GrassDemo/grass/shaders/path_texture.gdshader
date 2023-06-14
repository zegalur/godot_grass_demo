shader_type canvas_item;

global uniform float path_texture_scale;
global uniform float path_texture_player_radius;
global uniform float global_delta;

global uniform vec3 player_global_position;
global uniform vec3 player_prev_global_position;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

void fragment() {
	vec3 dv = player_global_position - player_prev_global_position;
	vec2 screen_pos = UV - vec2(0.5, 0.5);
	
	float player_spot = max(0.0, 1.0 - length(
			path_texture_scale * screen_pos / path_texture_player_radius));
	float border_fade = clamp((1.0 - length(2.0 * screen_pos)) * 3.0, 0.0, 1.0);
	
	vec3 prev_path_value = min(
			vec3(1.0, border_fade, 1.0),
			texture(screen_texture, UV + dv.xz / path_texture_scale).xyz);
	
	float prev_disp_val = prev_path_value.y;
	vec2 prev_disp_vec = prev_path_value.xz;
	
	float move_vel = length(dv.xz);
	vec2 move_vec = dv.xz / (2.0 * max(0.05, move_vel)) + 0.5;
	
	float coef = 1.0 - min(1.0, global_delta * 0.3);
	
	float next_disp_val = max(prev_disp_val * coef, player_spot);
	vec2 next_disp_vec = mix(prev_disp_vec, move_vec, move_vel * pow(player_spot, 0.2));
	
	COLOR = vec4(next_disp_vec.x, next_disp_val, next_disp_vec.y, 1.0);
}
