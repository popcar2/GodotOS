extends Window

func _physics_process(delta):
	position = get_parent().position
	position.y += 30
	size = get_parent().size
	size.y -= 30
	visible = get_parent().visible
