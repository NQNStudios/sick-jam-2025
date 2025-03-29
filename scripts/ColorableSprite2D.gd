@tool
extends AnimatedSprite2D

@export var init_colors:Array[Color] = []
@export var new_colors:Array[Color] = []

func get_init_colors():
	if init_colors.is_empty():
		var textures_to_check:Array[Texture2D] = []
		for anim_name in sprite_frames.get_animation_names():
			for frame_idx in range(sprite_frames.get_frame_count(anim_name)):
				var texture = sprite_frames.get_frame_texture(anim_name, frame_idx)
				if texture not in textures_to_check:
					textures_to_check.append(texture)
		for texture in textures_to_check:
			var image = texture.get_image()
			for px in range(texture.get_width()):
				for py in range(texture.get_height()):
					var color = image.get_pixel(px, py)
					if color.a != 0 and color not in init_colors:
						init_colors.append(color)
						if new_colors.size() < init_colors.size():
							new_colors.append(color)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_init_colors()
