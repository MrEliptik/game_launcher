extends TextureRect

var tween: Tween

func blend_textures(mix: float) -> void:
	material.set_shader_parameter("mix_value", mix)

func set_textures(texture_1: Texture, texture_2: Texture) -> void:
	material.set_shader_parameter("texture_1", texture_1)
	material.set_shader_parameter("texture_2", texture_2)

func get_shader_texture(id: int) -> Texture:
	if id == 0:
		return material.get_shader_parameter("texture_1")
	elif id == 1:
		return material.get_shader_parameter("texture_2")
	else:
		return null

func blend_textures_animated(texture_1: Texture, texture_2: Texture, duration: float) -> void:
	set_textures(texture_1, texture_2)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(blend_textures, 0.0, 1.0, duration)
