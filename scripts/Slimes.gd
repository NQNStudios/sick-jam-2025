extends Node2D

func sort():
	# Source: https://forum.godotengine.org/t/how-can-i-sort-the-children-of-a-node/1409/2
	# modified by NQNStudios
	var sorted_nodes := get_children()

	sorted_nodes.sort_custom(
		# For descending order use > 0
		func(a: Slime, b: Slime): return a.body.size > b.body.size
	)

	for node in get_children():
		remove_child(node)

	for node in sorted_nodes:
		add_child(node)
