extends SubViewport

var window: FakeWindow

func _ready():
	window = $"../../.."
	window.minimized.connect(_handle_window_minimized)
	window.selected.connect(_handle_window_selected)

func _handle_window_minimized(is_minimized: bool):
	if is_minimized:
		get_child(0).process_mode = Node.PROCESS_MODE_DISABLED
	else:
		get_child(0).process_mode = Node.PROCESS_MODE_INHERIT

func _handle_window_selected(is_selected: bool):
	# TODO figure out how to pause inputs here
	handle_input_locally = false
	get_child(0).set_process_input(false)
