extends Sprite2D

var elapsed = 0

func _process(delta):
	# Side to side to sprite limits
	offset.x = 160 * sin(elapsed / 2)
	# Up and down by an arbitrary amount just to seem liquidy
	offset.y = 10 * sin(elapsed / 1.5)
	elapsed += delta
