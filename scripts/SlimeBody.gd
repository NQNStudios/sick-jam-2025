@tool
class_name SlimeBody
extends RigidBody2D

@export var size = 1
@export var sprite_scale = 1.5
var base_radius = 12

const slime_types = {
	1: "slime",
	2: "slime2",
	4: "slime4",
	8: "slime8",
	16: "slime16"
}

# TODO make this bigger but exclude really big ones
const max_active_size = 4

@onready var shape = $Circle.shape

var alive = true
var on_fire = false

var Shover = preload("res://scenes/shover.tscn")

func _ready():
	contact_monitor = true
	max_contacts_reported = 1000
	$Sprite.scale = Vector2(sprite_scale, sprite_scale)
	set_shape()

func set_shape():
	$Circle.shape.radius = base_radius * sprite_scale

func _on_body_entered(body: Node) -> void:
	if alive and body is SlimeBody and body.alive:
		if body.size == size:
			alive = false
			body.alive = false
			if size * 2 not in slime_types:
				print("{0} + {1} = ???".format([size, body.size]))
			else:
				# Two slimes combine!
				print("{0} + {1} = {2}".format([size, body.size, size * 2]))
				
				body.get_parent().call_deferred("queue_free")
				get_parent().call_deferred("queue_free")
				
				var combined_scene = load("res://scenes/" + slime_types[size*2] + ".tscn")
				var combined = combined_scene.instantiate()
				combined.get_node("Body").set_shape()
				# TODO throw appropriately colored slime globs to cover up the sudden change 
				# Merge to the position of the more stationary slime:
				var new_position = global_position
				if body.linear_velocity.length() < linear_velocity.length():
					new_position = body.global_position
				
				var new_shape = combined.get_node("Body/Circle").shape
				
				var shover = Shover.instantiate()
				shover.global_position = new_position
				shover.get_node("Circle").shape = new_shape
				
				var pm = shover.get_node("Particles").process_material
				pm.color = combined.get_node("Body/Sprite").new_colors[2]
				pm.emission_sphere_radius = combined.get_node("Body/Circle").shape.radius
				combined.global_position = new_position
				shover.slime = combined
				
				var scene = get_tree().get_current_scene()
				scene.get_node("Shovers").call_deferred("add_child", shover)
