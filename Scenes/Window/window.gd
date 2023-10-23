extends Panel
class_name FakeWindow

var is_dragging: bool
var start_drag_position: Vector2
var mouse_start_drag_position: Vector2

var is_being_deleted: bool
var is_minimized: bool
var is_selected: bool = true

signal minimized(is_minimized: bool)
signal deleted()

func _ready():
	get_parent().move_child(self, 3)
	deselect_other_windows()
	
	modulate.a = 0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1, 0.5)

func _process(_delta):
	if is_dragging:
		global_position = start_drag_position + (get_global_mouse_position() - mouse_start_drag_position)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		select_window()

func _on_top_bar_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			select_window()
			is_dragging = true
			start_drag_position = global_position
			mouse_start_drag_position = get_global_mouse_position()
		else:
			is_dragging = false

func _on_close_button_pressed():
	if is_being_deleted:
		return
	
	deleted.emit()
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
	
	is_selected = false
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
	
	get_parent().move_child(self, 3)
	deselect_other_windows()
	
	is_minimized = false
	minimized.emit(is_minimized)
	
	visible = true
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 20, 0.25)
	tween.tween_property(self, "modulate:a", 1, 0.25)

func select_window():
	if is_selected:
		return
	
	is_selected = true
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1, 0.1)
	get_parent().move_child(self, 3)
	
	deselect_other_windows()

func deselect_window():
	if !is_selected:
		return
	
	is_selected = false
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.75, 0.25)

func deselect_other_windows():
	for window in get_tree().get_nodes_in_group("window"):
		if window == self: continue
		window.deselect_window()
