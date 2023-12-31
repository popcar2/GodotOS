extends SpinBox

var is_mouse_over: bool

func _ready():
	value = get_window().content_scale_factor

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !is_mouse_over:
		get_line_edit().release_focus()
	
	if event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
		await get_tree().process_frame
		value = get_window().content_scale_factor

func _on_mouse_entered():
	is_mouse_over = true

func _on_mouse_exited():
	is_mouse_over = false

func _on_value_changed(new_value):
	get_window().content_scale_factor = new_value

func _on_increment_scaling_pressed():
	if value + 0.125 > max_value:
		get_window().content_scale_factor = max_value
	else:
		get_window().content_scale_factor += 0.125
	value = get_window().content_scale_factor

func _on_decrement_scaling_pressed():
	if value - 0.125 < min_value:
		get_window().content_scale_factor = min_value
	else:
		get_window().content_scale_factor -= 0.125
	value = get_window().content_scale_factor
