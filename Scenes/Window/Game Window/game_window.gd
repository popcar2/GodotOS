extends SubViewport

var window: FakeWindow

func _ready():
	window = $"../../.."
	window.minimized.connect(_handle_window_minimized)

func _handle_window_minimized(is_minimized: bool):
	if is_minimized:
		get_child(0).process_mode = Node.PROCESS_MODE_DISABLED
	else:
		get_child(0).process_mode = Node.PROCESS_MODE_INHERIT
