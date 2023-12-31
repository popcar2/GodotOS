extends Control
class_name FakeFolder

enum file_type_enum {FOLDER, TEXT_FILE, IMAGE}
@export var file_type: file_type_enum

const FOLDER_COLOR: Color = Color("4efa82")
const TEXT_FILE_COLOR: Color = Color("4deff5")
const IMAGE_COLOR: Color = Color("ffed4c")

var folder_name: String
var folder_path: String # Relative to user://files/

var is_mouse_over: bool

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
	if event is InputEventMouseButton and event.is_pressed():
		if !is_mouse_over:
			hide_selected_highlight()
		else:
			show_selected_highlight()
			if !is_mouse_over or event.button_index != 1:
				return
			
			if $"Double Click".is_stopped():
				$"Double Click".start()
			else:
				accept_event()
				open_folder()
	if $"Selected Highlight".visible:
		if event.is_action_pressed("delete"):
			delete_file()
		elif event.is_action_pressed("copy"):
			CopyPasteManager.copy_folder(self)
		elif event.is_action_pressed("cut"):
			CopyPasteManager.cut_folder(self)
		
		if event.is_action_pressed("ui_up"):
			accept_event()
			get_parent().select_folder_up(self)
		elif event.is_action_pressed("ui_down"):
			accept_event()
			get_parent().select_folder_down(self)
		elif event.is_action_pressed("ui_left"):
			accept_event()
			get_parent().select_folder_left(self)
		elif event.is_action_pressed("ui_right"):
			accept_event()
			get_parent().select_folder_right(self)
		elif event.is_action_pressed("ui_accept"):
			accept_event()
			open_folder()

func _on_mouse_entered():
	show_hover_highlight()
	is_mouse_over = true

func _on_mouse_exited():
	hide_hover_highlight()
	is_mouse_over = false

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
	
	var taskbar_button: Control = load("res://Scenes/Taskbar/taskbar_button.tscn").instantiate()
	taskbar_button.target_window = window
	
	if file_type == file_type_enum.FOLDER:
		taskbar_button.active_color = FOLDER_COLOR
	if file_type == file_type_enum.TEXT_FILE:
		taskbar_button.active_color = TEXT_FILE_COLOR
	elif file_type == file_type_enum.IMAGE:
		taskbar_button.active_color = IMAGE_COLOR
	
	get_tree().get_first_node_in_group("taskbar_buttons").add_child(taskbar_button)

func delete_file():
	if file_type == file_type_enum.FOLDER:
		var delete_path: String = ProjectSettings.globalize_path("user://files/%s" % folder_path)
		if !DirAccess.dir_exists_absolute(delete_path):
			return
		OS.move_to_trash(delete_path)
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path.begins_with(folder_path):
				file_manager.close_window()
			elif get_parent() is FileManagerWindow and file_manager.file_path == get_parent().file_path:
				file_manager.delete_file_with_name(folder_name)
				file_manager.update_positions()
	else:
		var delete_path: String = ProjectSettings.globalize_path("user://files/%s/%s" % [folder_path, folder_name])
		if !FileAccess.file_exists(delete_path):
			return
		OS.move_to_trash(delete_path)
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path == folder_path:
				file_manager.delete_file_with_name(folder_name)
				file_manager.sort_folders()
	
	if folder_path.is_empty() or (file_type == file_type_enum.FOLDER and len(folder_path.split('/')) == 1):
		var desktop_file_manager: DesktopFileManager = get_tree().get_first_node_in_group("desktop_file_manager")
		desktop_file_manager.delete_file_with_name(folder_name)
		desktop_file_manager.sort_folders()
	# TODO make the color file_type dependent?
	NotificationManager.spawn_notification("Moved [color=59ea90][wave freq=7]%s[/wave][/color] to trash!" % folder_name)
	queue_free()

func open_folder():
	hide_selected_highlight()
	if get_parent().is_in_group("file_manager_window") and file_type == file_type_enum.FOLDER:
		get_parent().reload_window(folder_path)
	else:
		spawn_window()
