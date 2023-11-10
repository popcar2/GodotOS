extends Panel

var is_mouse_over: bool

func _ready():
	visible = false

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == 2 and !is_mouse_over:
			show_context_menu()
		elif event.button_index == 1 and !is_mouse_over and visible:
			hide_context_menu()

func show_context_menu():
	visible = true
	global_position = get_global_mouse_position() + Vector2(10, 15)
	clamp_inside_viewport()
	modulate.a = 0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.3)

func hide_context_menu():
	var tween: Tween = create_tween()
	await tween.tween_property(self, "modulate:a", 0, 0.15).finished
	if modulate.a == 0:
		visible = false

func _on_mouse_entered():
	is_mouse_over = true

func _on_mouse_exited():
	is_mouse_over = false

func clamp_inside_viewport():
	var game_window_size: Vector2 = get_viewport_rect().size
	if (size.y > game_window_size.y - 40):
		size.y = game_window_size.y - 40
	if (size.x > game_window_size.x):
		size.x = game_window_size.x
	
	global_position.y = clamp(global_position.y, 0, game_window_size.y - size.y - 40)
	global_position.x = clamp(global_position.x, 0, game_window_size.x - size.x)
