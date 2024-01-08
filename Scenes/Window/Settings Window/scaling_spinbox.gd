extends SpinBox

## The scaling spinbox in the settings menu.
## Also handles the + and - buttons next to it.

var is_mouse_over: bool

func _ready() -> void:
	value = get_window().content_scale_factor

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !is_mouse_over:
		get_line_edit().release_focus()
	
	if event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
		await get_tree().process_frame
		value = get_window().content_scale_factor

func _on_mouse_entered() -> void:
	is_mouse_over = true

func _on_mouse_exited() -> void:
	is_mouse_over = false

func _on_value_changed(new_value: float) -> void:
	get_window().content_scale_factor = new_value
	DefaultValues.save_state()

func _on_increment_scaling_pressed() -> void:
	if value + 0.125 > max_value:
		get_window().content_scale_factor = max_value
	else:
		get_window().content_scale_factor += 0.125
	value = get_window().content_scale_factor

func _on_decrement_scaling_pressed() -> void:
	if value - 0.125 < min_value:
		get_window().content_scale_factor = min_value
	else:
		get_window().content_scale_factor -= 0.125
	value = get_window().content_scale_factor
