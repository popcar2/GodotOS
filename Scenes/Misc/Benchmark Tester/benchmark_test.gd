extends Node

var windows: int

func _physics_process(_delta):
	window_spawner()

func window_spawner():
	get_tree().get_first_node_in_group("folder").spawn_window()
	windows += 1
	$RichTextLabel.text = "Windows: %d\nFPS: %d" % [windows, Performance.get_monitor(Performance.TIME_FPS)]
