extends Panel
class_name FakeWindow

@onready var top_bar: Panel = $"Top Bar"

static var num_of_windows: int

var title_text: String

var is_dragging: bool
var start_drag_position: Vector2
var mouse_start_drag_position: Vector2

var is_being_deleted: bool
var is_minimized: bool
var is_selected: bool
var is_maximized: bool

var maximize_icon: CompressedTexture2D = preload("res://Art/Icons/expand.png")
var unmaximize_icon: CompressedTexture2D = preload("res://Art/Icons/shrink.png")
var old_unmaximized_position: Vector2
var old_unmaximized_size: Vector2

var start_bg_color_alpha: float

signal minimized(is_minimized: bool)
signal selected(is_selected: bool)
signal maximized(is_maximized: bool)
signal deleted()

func _ready():
	# Duplicate theme override so values can be set without affecting other windows
	self["theme_override_styles/panel"] = self["theme_override_styles/panel"].duplicate()
	top_bar["theme_override_styles/panel"] = top_bar["theme_override_styles/panel"].duplicate()
	start_bg_color_alpha = self["theme_override_styles/panel"]["bg_color"].a
	
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
	if event is InputEventMouseButton and (event.button_index == 1 or event.button_index == 2) and event.is_pressed():
		select_window(true)

func _on_top_bar_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
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
	if !is_selected:
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

## Actually "focuses" the window and brings it to the front
func select_window(play_fade_animation: bool):
	if is_selected:
		return
	
	is_selected = true
	selected.emit(true)
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($"Top Bar/Title Text", "modulate", Color("3cffff"), 0.25)
	tween.tween_property(self["theme_override_styles/panel"], "shadow_size", 20, 0.25)
	if play_fade_animation:
		tween.tween_property(self, "modulate:a", 1, 0.1)
	
	get_parent().move_child(self, num_of_windows)
	
	deselect_other_windows()

func deselect_window():
	if !is_selected:
		return
	
	is_selected = false
	selected.emit(false)
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.75, 0.25)
	tween.tween_property($"Top Bar/Title Text", "modulate", Color.WHITE, 0.25)
	tween.tween_property(self["theme_override_styles/panel"], "shadow_size", 0, 0.25)

func deselect_other_windows():
	for window in get_tree().get_nodes_in_group("window"):
		if window == self:
			continue
		window.deselect_window()

func clamp_window_inside_viewport():
	var game_window_size: Vector2 = get_viewport_rect().size
	if (size.y > game_window_size.y - 40):
		size.y = game_window_size.y - 40
	if (size.x > game_window_size.x):
		size.x = game_window_size.x
	
	global_position.y = clamp(global_position.y, 0, game_window_size.y - size.y - 40)
	global_position.x = clamp(global_position.x, 0, game_window_size.x - size.x)

func _on_maximize_button_pressed():
	maximize_window()

func maximize_window():
	if is_maximized:
		is_maximized = !is_maximized
		$"Top Bar/HBoxContainer/Maximize Button".icon = maximize_icon
		
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", old_unmaximized_position, 0.25)
		tween.tween_property(self["theme_override_styles/panel"], "bg_color:a", start_bg_color_alpha, 0.25)
		await tween.tween_property(self, "size", old_unmaximized_size, 0.25).finished
		
		self["theme_override_styles/panel"].set_corner_radius_all(5)
		top_bar["theme_override_styles/panel"]["corner_radius_top_left"] = 5
		top_bar["theme_override_styles/panel"]["corner_radius_top_right"] = 5
		
		$"Resize Drag Spot".window_resized.emit()
	else:
		is_maximized = !is_maximized
		$"Top Bar/HBoxContainer/Maximize Button".icon = unmaximize_icon
		
		old_unmaximized_position = global_position
		old_unmaximized_size = size
		
		var new_size = get_viewport_rect().size
		new_size.y -= 40 #Because taskbar
		
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", Vector2.ZERO, 0.25)
		tween.tween_property(self["theme_override_styles/panel"], "bg_color:a", 1, 0.25)
		await tween.tween_property(self, "size", new_size, 0.25).finished
		
		self["theme_override_styles/panel"].set_corner_radius_all(0)
		top_bar["theme_override_styles/panel"]["corner_radius_top_left"] = 0
		top_bar["theme_override_styles/panel"]["corner_radius_top_right"] = 0
		
		$"Resize Drag Spot".window_resized.emit()
