extends Control

func _ready():
	$"Hover Highlight".self_modulate.a = 0
	$"Selected Highlight".visible = false

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0), size).has_point(evLocal.position):
			hide_selected_highlight()
		else:
			show_selected_highlight()

func _on_mouse_entered():
	show_hover_highlight()

func _on_mouse_exited():
	hide_hover_highlight()

# ------

func show_hover_highlight():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($"Hover Highlight", "self_modulate:a", 1, 0.25).from(0.1)

func hide_hover_highlight():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($"Hover Highlight", "self_modulate:a", 0, 0.25)

func show_selected_highlight():
	$"Selected Highlight".visible = true

func hide_selected_highlight():
	$"Selected Highlight".visible = false
