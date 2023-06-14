extends Node3D

const PLAYER_SPEED = 10.0

var _first_frame := true
var _last_global_pos := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set path texture.
	var grass_material = $Grass/Grass01.material_override as ShaderMaterial
	var path_texture = $PathTexture/PathPreview.texture
	grass_material.set_shader_parameter("player_path_texture", path_texture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Hide the clear rect after the first frame.
	if not _first_frame:
		$PathTexture/SubViewport/Clear.hide()
	_first_frame = false
	
	# Set delta time. 'delta' is zero if game is paused.
	var delta_value = 0.0 if get_tree().paused else delta
	RenderingServer.global_shader_parameter_set("global_delta", delta_value)
	
	# Handle player input.
	var player = $Player as Node3D
	var input_dir = Input.get_vector(
			"move_left", 
			"move_right", 
			"move_up", 
			"move_down")
	player.translate(Vector3(input_dir.x, 0, input_dir.y) * delta * PLAYER_SPEED)
	
	# Set player_global_position uniform value.
	RenderingServer.global_shader_parameter_set(
			"player_prev_global_position", _last_global_pos)
	RenderingServer.global_shader_parameter_set(
			"player_global_position", player.global_position)
	_last_global_pos = player.global_position
