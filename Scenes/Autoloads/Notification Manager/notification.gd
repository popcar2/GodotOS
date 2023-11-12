extends Panel

func _ready():
	adjust_width()
	play_animation()

func adjust_width():
	while true:
		if $"Notification Text".get_line_count() > 1:
			size.x += 20
			position.x -= 20
		else:
			size.x += 10
			position.x -= 10
			return

func play_animation():
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y - 75, 3)
	
	await get_tree().create_timer(2).timeout
	var fade: Tween = create_tween()
	fade.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	await fade.tween_property(self, "modulate:a", 0, 1.5).finished
	queue_free()
