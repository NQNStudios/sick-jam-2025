extends Node2D

@export var base_lava_speed = 10

var lava_velocity = Vector2()

func _ready():
	# TODO delay till after triggered
	# TODO vary velocity by difficulty scaling, maybe by size of largest slimes, etc.
	lava_velocity = Vector2(0,-base_lava_speed)

func _process(delta):
	$Lava.transform.origin += lava_velocity * delta


func _on_lava_body_entered(body: Node2D) -> void:
	if body is SlimeBody and body.alive:
		body.alive = false
		body.get_node("Sprite/Fire").visible = true
