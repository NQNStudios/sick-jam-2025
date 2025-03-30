extends Area2D

var slime:Slime

func _on_body_entered(body: Node2D) -> void:
	if not physics_processed and body is SlimeBody:
		body.apply_impulse(body.global_position - global_position, global_position)

var physics_processed = false
var physics_process_started = false
func _physics_process(_delta: float) -> void:
	if physics_process_started:
		physics_processed = true
	physics_process_started = true
	
func _process(_delta: float) -> void:
	if physics_processed:
		var tree = get_tree()
		
		await tree.create_timer(0.1).timeout
		call_deferred("free")
		var slimes = tree.get_current_scene().get_node("Slimes")
		slimes.call_deferred("add_child", slime)
		slimes.call_deferred("sort")
		
