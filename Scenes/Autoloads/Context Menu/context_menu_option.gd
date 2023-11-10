extends Panel
class_name ContextMenuOption

signal option_clicked()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		option_clicked.emit()

func _on_mouse_entered():
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate:a", 1, 0.2)

func _on_mouse_exited():
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate:a", 0.3, 0.2)
