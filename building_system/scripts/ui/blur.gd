extends ColorRect

func _ready():
	size = get_viewport_rect().size
	material.set_shader_parameter("viewport_size", size)
