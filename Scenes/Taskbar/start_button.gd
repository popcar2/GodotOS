extends MarginContainer

## The start menu in the taskbar. Handles showing and hiding the start menu.

var is_mouse_over_menu: bool
var is_mouse_over: bool

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		handle_mouse_click()

func _on_mouse_entered() -> void:
	add_theme_constant_override("margin_bottom", 5)
	add_theme_constant_override("margin_left", 5)
	add_theme_constant_override("margin_right", 5)
	add_theme_constant_override("margin_top", 5)
	is_mouse_over = true

func _on_mouse_exited() -> void:
	add_theme_constant_override("margin_bottom", 3)
	add_theme_constant_override("margin_left", 3)
	add_theme_constant_override("margin_right", 3)
	add_theme_constant_override("margin_top", 3)
	is_mouse_over = false

func handle_mouse_click() -> void:
	if is_mouse_over_menu: # Mouse clicked on empty space in menu, do nothing
		return
	
	if is_mouse_over:
		if $"../Start Menu".position.y == 50:
			show_start_menu()
		else:
			hide_start_menu()
	else:
		hide_start_menu()

func show_start_menu() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($"../Start Menu", "position:y", -405, 0.3).from(-50)

func hide_start_menu() -> void:
	# Called from clicking on desktop
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($"../Start Menu", "position:y", 50, 0.3)

func _on_start_menu_mouse_entered() -> void:
	is_mouse_over_menu = true

func _on_start_menu_mouse_exited() -> void:
	is_mouse_over_menu = false
