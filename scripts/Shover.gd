extends Area2D

var slime:Slime

func _on_body_entered(body: Node2D) -> void:
	if body is SlimeBody:
		body.apply_impulse(body.global_position - global_position, global_position)

var physics_processed = false

func _physics_process(_delta: float) -> void:
	physics_processed = true
	
func _process(_delta: float) -> void:
	if physics_processed:
		var tree = get_tree()
		call_deferred("free")
		tree.get_current_scene().get_node("Shovers").call_deferred("add_child", slime)
