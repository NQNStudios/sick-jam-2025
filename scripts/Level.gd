extends Node2D

@export var base_lava_speed = 3

var lava_velocity = Vector2()

var active_slime: Slime = null
var drop_y = 16
var paused = false


func _ready():
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
	if paused:
		return
	if OS.is_debug_build() and event.is_action_pressed("debug_spawn"):
		drop_and_spawn(16)
	elif event.is_action_pressed("drop_slime"):
		drop_and_spawn()
	elif event is InputEventMouseMotion:
		if active_slime != null:
			active_slime.global_position.x = event.position.x
			active_slime.global_position.x = clamp(active_slime.global_position.x, active_slime.body.shape.radius, 640-active_slime.body.shape.radius)

func _process(delta):
	if not paused:
		$Lava.transform.origin += lava_velocity * delta
		if active_slime != null:
			active_slime.global_position.y = drop_y

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

func drop_and_spawn(size = -1):
	if active_slime != null:
		var x = active_slime.global_position.x
		active_slime.body.freeze = false
		active_slime = null
		var rung = $NextRung
		remove_child(rung) # let it fall past the next-level trigger area

		await get_tree().create_timer(1).timeout
		add_child(rung)
		spawn_active_slime(x, size)
		
func spawn_active_slime(x, size = -1):
	var types = SlimeBody.slime_types
	if size == -1:
		size = next_slime_size()
	var type = types[size]
	active_slime = load("res://scenes/" + type + ".tscn").instantiate()
	$Slimes.add_child(active_slime)
	$Slimes.sort()
	active_slime.body.freeze = true
	active_slime.global_position.y = drop_y
	active_slime.global_position.x = x

func _on_lava_body_entered(body: Node2D) -> void:
	if body is SlimeBody and not body.on_fire:
		body.on_fire = true
		body.get_node("Sprite/Fire").visible = true

@onready var next_ladder = $Background/Ladder
@onready var next_cave_wall = $Background/CaveWall

@onready var next_wall_left = $Bounds/Wall
@onready var next_wall_right = $Bounds/Wall2
@onready var next_lower_rung = $Bounds/LowerRung

var level = 0

func _on_next_rung_body_entered(body: Node2D) -> void:
	if body is SlimeBody and not body.on_fire and not body.freeze:
		# Go up a level!
		level += 1
		
		$NextRung.global_position.y -= 480
		drop_y -= 480

		if level % 2 == 1:
			next_cave_wall = next_cave_wall.duplicate(true)
			next_cave_wall.global_position.y -= 960
			$Background.call_deferred("add_child", next_cave_wall)
		next_ladder = next_ladder.duplicate(true)
		next_ladder.global_position.y -= 480
		$Background.call_deferred("add_child", next_ladder)
		
		next_wall_left = next_wall_left.duplicate()
		next_wall_left.global_position.y -= 480
		$Bounds.call_deferred("add_child", next_wall_left)
		next_wall_right = next_wall_right.duplicate()
		next_wall_right.global_position.y -= 480
		$Bounds.call_deferred("add_child", next_wall_right)
		next_wall_right = next_wall_right.duplicate()
		next_wall_right.global_position.y -= 480
		$Bounds.call_deferred("add_child", next_wall_right)
		
		# Lower slimes all remove from physics
		var bodies = []
		var slimes = $Slimes.get_children()
		for slime in slimes:
			if slime == active_slime:
				bodies.append(null)
				continue
			var sbody = slime.body
			bodies.append(sbody)
			slime.remove_child(sbody)
			var sprite = sbody.get_node("Sprite")
			sprite.transform = sbody.transform
			sprite.scale = Vector2(sbody.sprite_scale, sbody.sprite_scale)
			sbody.remove_child(sprite)
			slime.add_child(sprite)
		
		next_lower_rung = next_lower_rung.duplicate()
		next_lower_rung.global_position.y -= 480
		$Bounds.call_deferred("add_child", next_lower_rung)
		
		$Paused.global_position.y -= 480
		
		var tween = get_tree().create_tween()
		tween.tween_property($Camera, "global_position:y", $Camera.global_position.y - 480, 1)
		await tween.finished

		# TODO the guy who made it to the top and is stuck should have a voice bubble:
		# WAIT! I'M STUCK!
		# YOU SAID I'D KEEP GROWING!
		# YOU SAID I'D REACH THE TOP!

		var idx = 0
		for slime in slimes:
			if bodies[idx] != null and slime.global_position.y - bodies[idx].shape.radius > next_lower_rung.global_position.y:
				slime.call_deferred("queue_free")
				body.call_deferred("queue_free")
			idx += 1
		
