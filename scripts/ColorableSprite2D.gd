@tool
extends AnimatedSprite2D

@export var init_colors:Array[Color] = []
var init_color_indices = {}
@export var new_colors:Array[Color] = []
var new_colors_active = []
var textures:Array[Texture2D] = []
var new_textures:Array[Texture2D] = []

func get_textures():
	if textures.is_empty():
		for anim_name in sprite_frames.get_animation_names():
			for frame_idx in range(sprite_frames.get_frame_count(anim_name)):
				var texture = sprite_frames.get_frame_texture(anim_name, frame_idx)
				if texture not in textures:
					textures.append(texture)
	return textures

func get_init_colors():
	if init_colors.is_empty():
		for texture in get_textures():
			var image = texture.get_image()
			for px in range(texture.get_width()):
				for py in range(texture.get_height()):
					var color = image.get_pixel(px, py)
					if color.a != 0 and color not in init_colors:
						init_colors.append(color)
						if new_colors.size() < init_colors.size():
							new_colors.append(color)
		while new_colors.size() > init_colors.size():
			new_colors.pop_back()
		for color_idx in range(init_colors.size()):
			init_color_indices[init_colors[color_idx]] = color_idx
	return init_colors

func apply_swap():
	var modified = new_colors_active.size() != new_colors.size()
	if not modified:
		for color_idx in range(new_colors.size()):
			if new_colors[color_idx] != new_colors_active[color_idx]:
				modified = true
	
	if not modified:
		return
	
	new_colors_active = new_colors
	print("applying swap")
	sprite_frames = sprite_frames.duplicate(true)

	var done_textures = []
	var old_new_textures = new_textures
	new_textures = []
	
	for texture in textures:
		if texture in done_textures:
			continue
		var new_texture = texture.duplicate(true)
		var image = new_texture.get_image().duplicate(true)
		for px in image.get_width():
			for py in image.get_height():
				var init_color = image.get_pixel(px, py)
				if init_color in init_color_indices:
					var new_color = new_colors[init_color_indices[init_color]]
					if init_color != new_color:
						image.set_pixel(px, py, new_color)
		new_textures.append(new_texture)
		done_textures.append(texture)
	
	for anim_name in sprite_frames.get_animation_names():
		for frame_idx in range(sprite_frames.get_frame_count(anim_name)):
			var texture = sprite_frames.get_frame_texture(anim_name, frame_idx)
			var texture_idx = textures.find(texture)
			if texture_idx == -1:
				texture_idx = old_new_textures.find(texture)
			var duration = sprite_frames.get_frame_duration(anim_name, frame_idx)
			sprite_frames.set_frame(anim_name, frame_idx, new_textures[texture_idx], duration)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_textures()
	get_init_colors()
	apply_swap()
	play("idle", 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		apply_swap()
