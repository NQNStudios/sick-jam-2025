extends Node2D

@export var base_lava_speed = 3

var lava_velocity = Vector2()

var active_slime: Slime = null
var paused = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	randomize()
	
	spawn_active_slime(320)
	
	# TODO delay till after triggered
	start_lava()
	
func start_lava():
	# TODO vary velocity by difficulty scaling, maybe by size of largest slimes, etc.
	lava_velocity = Vector2(0,-base_lava_speed)

func _input(event):
	if event.is_action_pressed("pause"):
		paused = !paused
		$Paused.visible = paused
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
	if paused:
		return
	if event.is_action_pressed("drop_slime"):
		if active_slime != null:
			var x = active_slime.global_position.x
			active_slime.body.freeze = false
			active_slime = null
			

			await get_tree().create_timer(1).timeout

			spawn_active_slime(x)
	elif event is InputEventMouseMotion:
		if active_slime != null:
			active_slime.global_position.x += event.screen_relative.x
			active_slime.global_position.x = clamp(active_slime.global_position.x, active_slime.body.shape.radius, 640-active_slime.body.shape.radius)

func _process(delta):
	if not paused:
		$Lava.transform.origin += lava_velocity * delta
		if active_slime != null:
			active_slime.global_position.y = 16

const upgrade_chance = 0.5
var first_time = true
func next_slime_size():
	var size = 1
	if first_time:
		first_time = false
		return size
	while size < SlimeBody.max_active_size:
		if randf() <= upgrade_chance:
			size *= 2
		else:
			break
	return size
		
func spawn_active_slime(x):
	var types = SlimeBody.slime_types
	var type = types[next_slime_size()]
	active_slime = load("res://scenes/" + type + ".tscn").instantiate()
	$Slimes.add_child(active_slime)
	active_slime.body.freeze = true
	active_slime.global_position.y = 16
	active_slime.global_position.x = x

func _on_lava_body_entered(body: Node2D) -> void:
	if body is SlimeBody and not body.on_fire:
		body.on_fire = true
		body.get_node("Sprite/Fire").visible = true
