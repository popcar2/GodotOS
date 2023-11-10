extends Panel

func _on_mouse_entered():
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate:a", 1, 0.2)

func _on_mouse_exited():
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate:a", 0, 0.2)
