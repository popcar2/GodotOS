extends Panel
class_name FakeWindow

static var num_of_windows: int

var title_text: String

var is_dragging: bool
var start_drag_position: Vector2
var mouse_start_drag_position: Vector2

var is_being_deleted: bool
var is_minimized: bool
var is_selected: bool

signal minimized(is_minimized: bool)
signal deleted()

func _ready():
	num_of_windows += 1
	select_window(false)
	
	$"Top Bar/Title Text".text = " ".join(title_text.split("\n"))
	
	get_viewport().size_changed.connect(clamp_window_inside_viewport)
	
	modulate.a = 0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1, 0.5)

func _physics_process(_delta):
	if is_dragging:
		global_position = start_drag_position + (get_global_mouse_position() - mouse_start_drag_position)
		clamp_window_inside_viewport()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		select_window(true)

func _on_top_bar_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			select_window(true)
			is_dragging = true
			start_drag_position = global_position
			mouse_start_drag_position = get_global_mouse_position()
		else:
			is_dragging = false

func _on_close_button_pressed():
	if is_being_deleted:
		return
	
	deleted.emit()
	num_of_windows -= 1
	is_being_deleted = true
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	await tween.tween_property(self, "modulate:a", 0, 0.25).finished
	queue_free()

func _on_minimize_button_pressed():
	hide_window()


func hide_window():
	if is_minimized:
		return
	
	deselect_window()
	is_minimized = true
	minimized.emit(is_minimized)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 20, 0.25)
	await tween.tween_property(self, "modulate:a", 0, 0.25).finished
	visible = false

func show_window():
	if !is_minimized:
		return
	
	select_window(false)
	
	is_minimized = false
	minimized.emit(is_minimized)
	
	visible = true
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 20, 0.25)
	tween.tween_property(self, "modulate:a", 1, 0.25)

func select_window(play_fade_animation: bool):
	if is_selected:
		return
	
	is_selected = true
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($"Top Bar/Title Text", "modulate", Color("3cffff"), 0.25)
	if play_fade_animation:
		tween.tween_property(self, "modulate:a", 1, 0.1)
	
	get_parent().move_child(self, num_of_windows)
	
	deselect_other_windows()

func deselect_window():
	if !is_selected:
		return
	
	is_selected = false
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.75, 0.25)
	tween.tween_property($"Top Bar/Title Text", "modulate", Color.WHITE, 0.25)

func deselect_other_windows():
	for window in get_tree().get_nodes_in_group("window"):
		if window == self: continue
		window.deselect_window()

func clamp_window_inside_viewport():
	var game_window_size: Vector2 = DisplayServer.window_get_size()
	global_position.y = clamp(global_position.y, 0, game_window_size.y - size.y - 40)
	global_position.x = clamp(global_position.x, 0, game_window_size.x - size.x)
