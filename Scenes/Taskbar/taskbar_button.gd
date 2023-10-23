extends MarginContainer

var target_window: FakeWindow

var active_color: Color = Color("6de700")
var disabled_color: Color = Color("908a8c")

func _ready():
	target_window.minimized.connect(on_window_minimized)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		if target_window.is_minimized:
			target_window.show_window()
		else:
			target_window.hide_window()

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

func on_window_minimized(is_minimized: bool):
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if is_minimized:
		tween.tween_property($TextureRect, "self_modulate", disabled_color, 0.25)
	else:
		tween.tween_property($TextureRect, "self_modulate", active_color, 0.25)
