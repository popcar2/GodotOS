extends Control
class_name FakeFolder

enum file_type_enum {FOLDER, TEXT_FILE}
@export var file_type: file_type_enum

var folder_name: String
var folder_path: String # Relative to user://files/

var mouse_over: bool

func _ready():
	$"Hover Highlight".self_modulate.a = 0
	$"Selected Highlight".visible = false
	%"Folder Title".text = "[center]%s" % folder_name
	
	if file_type == file_type_enum.FOLDER:
		$Folder/TextureRect.modulate = Color("4efa82")
	elif file_type == file_type_enum.TEXT_FILE:
		$Folder/TextureRect.modulate = Color("4deff5")

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0), size).has_point(evLocal.position):
			hide_selected_highlight()
		else:
			if !mouse_over:
				return
			
			if $"Double Click".is_stopped():
				show_selected_highlight()
				$"Double Click".start()
			else:
				hide_selected_highlight()
				if folder_path.is_empty() or file_type != file_type_enum.FOLDER:
					spawn_window()
				else:
					get_parent().reload_window(folder_path)

func _on_mouse_entered():
	show_hover_highlight()
	mouse_over = true

func _on_mouse_exited():
	hide_hover_highlight()
	mouse_over = false

# ------

func show_hover_highlight():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($"Hover Highlight", "self_modulate:a", 1, 0.25).from(0.1)

func hide_hover_highlight():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($"Hover Highlight", "self_modulate:a", 0, 0.25)

func show_selected_highlight():
	$"Selected Highlight".visible = true

func hide_selected_highlight():
	$"Selected Highlight".visible = false

func spawn_window():
	var window: FakeWindow
	if file_type == file_type_enum.FOLDER:
		window = load("res://Scenes/Window/File Manager/file_manager_window.tscn").instantiate()
		window.get_node("%File Manager Window").file_path = folder_path + folder_name
	elif file_type == file_type_enum.TEXT_FILE:
		window = load("res://Scenes/Window/Text Editor/text_editor.tscn").instantiate()
		# TODO make this more flexible?
		if folder_path.is_empty():
			window.get_node("%Text Editor").populate_text(folder_name)
		else:
			window.get_node("%Text Editor").populate_text(folder_path)
	
	window.title_text = %"Folder Title".text
	get_tree().current_scene.add_child(window)
	
	var taskbar_button: MarginContainer = load("res://Scenes/Taskbar/taskbar_button.tscn").instantiate()
	taskbar_button.target_window = window
	get_tree().get_first_node_in_group("taskbar_buttons").add_child(taskbar_button)
