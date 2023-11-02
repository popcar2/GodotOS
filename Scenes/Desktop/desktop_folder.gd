extends Control
class_name FakeFolder

enum file_type_enum {FOLDER, TEXT_FILE, IMAGE}
@export var file_type: file_type_enum

const FOLDER_COLOR: Color = Color("4efa82")
const TEXT_FILE_COLOR: Color = Color("4deff5")
const IMAGE_COLOR: Color = Color("ffed4c")

var folder_name: String
var folder_path: String # Relative to user://files/

var mouse_over: bool

func _ready():
	$"Hover Highlight".self_modulate.a = 0
	$"Selected Highlight".visible = false
	%"Folder Title".text = "[center]%s" % folder_name
	
	if file_type == file_type_enum.FOLDER:
		$Folder/TextureRect.modulate = FOLDER_COLOR
	elif file_type == file_type_enum.TEXT_FILE:
		$Folder/TextureRect.modulate = TEXT_FILE_COLOR
	elif file_type == file_type_enum.IMAGE:
		$Folder/TextureRect.modulate = IMAGE_COLOR

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
				if get_parent().is_in_group("file_manager_window") and file_type == file_type_enum.FOLDER:
					get_parent().reload_window(folder_path)
				else:
					spawn_window()

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
		window.get_node("%File Manager Window").file_path = folder_path
	elif file_type == file_type_enum.TEXT_FILE:
		window = load("res://Scenes/Window/Text Editor/text_editor.tscn").instantiate()
		# TODO make this more flexible?
		if folder_path.is_empty():
			window.get_node("%Text Editor").populate_text(folder_name)
		else:
			window.get_node("%Text Editor").populate_text("%s/%s" % [folder_path, folder_name])
	elif file_type == file_type_enum.IMAGE:
		window = load("res://Scenes/Window/Image Viewer/image_viewer.tscn").instantiate()
		if folder_path.is_empty():
			window.get_node("%Image Viewer").import_image(folder_name)
		else:
			window.get_node("%Image Viewer").import_image("%s/%s" % [folder_path, folder_name])
	
	window.title_text = %"Folder Title".text
	get_tree().current_scene.add_child(window)
	
	var taskbar_button: MarginContainer = load("res://Scenes/Taskbar/taskbar_button.tscn").instantiate()
	taskbar_button.target_window = window
	
	if file_type == file_type_enum.FOLDER:
		taskbar_button.active_color = FOLDER_COLOR
	if file_type == file_type_enum.TEXT_FILE:
		taskbar_button.active_color = TEXT_FILE_COLOR
	elif file_type == file_type_enum.IMAGE:
		taskbar_button.active_color = IMAGE_COLOR
	
	get_tree().get_first_node_in_group("taskbar_buttons").add_child(taskbar_button)
