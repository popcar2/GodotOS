extends Control

var is_dragging: bool

var start_size: Vector2
var mouse_start_drag_position: Vector2

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			is_dragging = true
			mouse_start_drag_position = get_global_mouse_position()
			start_size = get_parent().size
		else:
			is_dragging = false

func _physics_process(_delta):
	if is_dragging:
		get_parent().size = start_size + get_global_mouse_position() - mouse_start_drag_position
