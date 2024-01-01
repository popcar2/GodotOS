extends Button

func _on_pressed() -> void:
	var window: FakeWindow
	window = load("res://Scenes/Window/Settings Window/settings_window.tscn").instantiate()
	
	window.title_text = "[center]Settings Menu"
	get_tree().current_scene.add_child(window)
	
	var taskbar_button: Control = load("res://Scenes/Taskbar/taskbar_button.tscn").instantiate()
	taskbar_button.target_window = window
	taskbar_button.active_color = Color.WHITE
	get_tree().get_first_node_in_group("taskbar_buttons").add_child(taskbar_button)
