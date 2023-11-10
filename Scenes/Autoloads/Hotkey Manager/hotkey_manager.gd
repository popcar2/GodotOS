extends Node

func _input(event: InputEvent):
	if event.is_action_pressed("kill_all_windows"):
		for window in get_tree().get_nodes_in_group("window"):
			window._on_close_button_pressed()
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if event.is_action_pressed("open_in_file_manager"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://files/"))
	
	#TODO notification for zoom levels
	if event.is_action_pressed("zoom_in"):
		if get_tree().root.content_scale_factor < 4:
			get_tree().root.content_scale_factor += 0.125
	elif event.is_action_pressed("zoom_out"):
		if get_tree().root.content_scale_factor > 0.25:
			get_tree().root.content_scale_factor -= 0.125
