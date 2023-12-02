extends MarginContainer

var is_mouse_over_menu: bool

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		handle_mouse_click(event)

func _on_mouse_entered():
	add_theme_constant_override("margin_bottom", 7)
	add_theme_constant_override("margin_left", 7)
	add_theme_constant_override("margin_right", 7)
	add_theme_constant_override("margin_top", 7)

func _on_mouse_exited():
	add_theme_constant_override("margin_bottom", 5)
	add_theme_constant_override("margin_left", 5)
	add_theme_constant_override("margin_right", 5)
	add_theme_constant_override("margin_top", 5)

func handle_mouse_click(event: InputEvent):
	if is_mouse_over_menu: # Mouse clicked on empty space, do nothing
		return
	
	var evLocal = make_input_local(event)
	if !Rect2(Vector2(0,0), size).has_point(evLocal.position):
		hide_start_menu()
	else:
		if $"../Start Menu".position.y == 50:
			show_start_menu()
		else:
			hide_start_menu()

func show_start_menu():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($"../Start Menu", "position:y", -405, 0.3).from(-50)

func hide_start_menu():
	# Called from clicking on desktop
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($"../Start Menu", "position:y", 50, 0.4)

func _on_start_menu_mouse_entered():
	is_mouse_over_menu = true

func _on_start_menu_mouse_exited():
	is_mouse_over_menu = false
