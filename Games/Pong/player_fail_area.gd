extends Area2D

func _on_body_entered(body):
	if body.name == "Ball":
		get_parent().enemy_score += 1
		body.reset_ball()
