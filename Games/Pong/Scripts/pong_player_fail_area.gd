extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		get_parent().enemy_score += 1
		body.reset_ball()
