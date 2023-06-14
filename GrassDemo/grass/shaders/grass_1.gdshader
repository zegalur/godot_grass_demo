shader_type spatial;
render_mode cull_disabled;

global uniform float path_texture_scale;
global uniform vec3 player_global_position;

uniform sampler2D player_path_texture : repeat_disable, hint_default_black;

uniform sampler2D albedo : source_color;
uniform sampler2D roughness : hint_roughness_gray;
uniform sampler2D nmap : hint_normal;

uniform vec3 backlight : source_color;

void vertex() {
	// Get vertex global position.
	vec3 gpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// Get vector from global position to player global pos.
	vec3 dif = (gpos - player_global_position) * vec3(1.0, 0.0, 1.0);
	vec2 center = vec2(0.5, 0.5);
	
	// Get path value.
	vec3 path_value = texture(
			player_path_texture, center + dif.xz / path_texture_scale).xyz;
	
	vec3 dbase = normalize(VERTEX * vec3(1.0, -0.2, 1.0));
	vec2 displace_vector = path_value.xz * 2.0 - 1.0;
	float displace_value = path_value.y;
	displace_vector *= displace_value;
	
	vec3 new_gpos = gpos + 5.0 * min(VERTEX.y * 0.5, 1.0) * vec3(
			displace_vector.x, -0.1 * displace_value, displace_vector.y);
	
	vec4 new_pos_local = (
			inverse(MODEL_MATRIX)
			* vec4(new_gpos, 1.0));
	VERTEX = new_pos_local.xyz;
}

void fragment() {
	vec4 albedo_alpha = texture(albedo, UV);
	if(albedo_alpha.a < 0.35)
		discard;
	
	ALBEDO = albedo_alpha.rgb;
	ROUGHNESS = texture(roughness, UV).x;
	NORMAL_MAP = texture(nmap, UV).xyz;
	BACKLIGHT = backlight.rgb;
}
