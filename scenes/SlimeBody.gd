class_name SlimeBody
extends RigidBody2D

@export var size = 1

var slime_types = {
	1: "slime",
	2: "slime-different"
}

var alive = true

func _ready():
	contact_monitor = true
	max_contacts_reported = 1000


func _on_body_entered(body: Node) -> void:
	if alive and body is SlimeBody and body.alive:
		if body.size == size:
			alive = false
			body.alive = false
			# Two slimes combine!
			print("{0} + {1} = {2}".format([size, body.size, size * 2]))
			var combined_scene = load("res://scenes/" + slime_types[size*2] + ".tscn")
			var combined = combined_scene.instantiate()
			combined.transform.origin = get_parent().transform.origin
			body.get_parent().call_deferred("queue_free")
			get_parent().call_deferred("queue_free")
			var scene = get_tree().get_current_scene()
			scene.call_deferred("add_child", combined)
