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
