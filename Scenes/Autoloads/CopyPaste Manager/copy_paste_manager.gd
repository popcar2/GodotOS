extends Node
## Copies and pastes folders and files

## The target folder. NOT used for variables since it could be freed by a file manager window!
var target_folder: FakeFolder
var target_folder_name: String
var target_folder_path: String
var target_folder_type: FakeFolder.file_type_enum

enum StateEnum{COPY, CUT}
var state: StateEnum = StateEnum.COPY

func _ready() -> void:
	get_viewport().files_dropped.connect(_handle_dropped_folders)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_paste"):
		var selected_window: FakeWindow = GlobalValues.selected_window
		# Paste in desktop if no selected window. Paste in file manager if file manager is selected.
		if !selected_window:
			#paste_folder(target_folder.folder_name)
			pass
		if selected_window and !selected_window.get_node_or_null("%Text Editor") and !selected_window.get_node_or_null("%Image Viewer"):
			print("Text or image")

func copy_folder(folder: FakeFolder) -> void:
	if target_folder:
		target_folder.modulate.a = 1
	target_folder = folder
	
	target_folder_name = folder.folder_name
	target_folder_path = folder.folder_path
	target_folder_type = folder.file_type
	folder.modulate.a = 0.8
	state = StateEnum.COPY
	NotificationManager.spawn_notification("Copied [color=59ea90][wave freq=7]%s[/wave][/color]" % target_folder_name)

func cut_folder(folder: FakeFolder) -> void:
	if target_folder:
		target_folder.modulate.a = 1
	target_folder = folder
	target_folder.modulate.a = 0.8
	
	target_folder_name = folder.folder_name
	target_folder_path = folder.folder_path
	target_folder_type = folder.file_type
	state = StateEnum.CUT
	NotificationManager.spawn_notification("Cutting [color=59ea90][wave freq=7]%s[/wave][/color]" % target_folder_name)

func paste_folder(to_path: String) -> void:
	if target_folder_name.is_empty():
		NotificationManager.spawn_notification("Error: Nothing to copy")
		return
	
	if state == StateEnum.COPY:
		paste_folder_copy(to_path)
	elif state == StateEnum.CUT:
		paste_folder_cut(to_path)

func paste_folder_copy(to_path: String) -> void:
	var to: String = "user://files/%s/%s" % [to_path, target_folder_name]
	if target_folder_type == FakeFolder.file_type_enum.FOLDER:
		var from: String = "user://files/%s" % target_folder_path
		DirAccess.make_dir_absolute(to)
		copy_directory_recursively(from, to)
	else:
		var from: String = "user://files/%s/%s" % [target_folder_path, target_folder_name]
		DirAccess.copy_absolute(from, to)
	
	if target_folder != null:
		target_folder.modulate.a = 1
	if to_path.is_empty():
		var desktop_file_manager: DesktopFileManager = get_tree().get_first_node_in_group("desktop_file_manager")
		instantiate_file_and_sort(desktop_file_manager, to_path)
	else:
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path == to_path:
				instantiate_file_and_sort(file_manager, to_path)
	
	target_folder_name = ""
	target_folder = null

func paste_folder_cut(to_path: String) -> void:
	var to: String = "user://files/%s/%s" % [to_path, target_folder_name]
	if target_folder_type == FakeFolder.file_type_enum.FOLDER:
		var from: String = "user://files/%s" % target_folder_path
		DirAccess.rename_absolute(from, to)
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path.begins_with(target_folder_path):
				file_manager.close_window()
			elif file_manager.file_path == to_path:
				instantiate_file_and_sort(file_manager, to_path)
	else:
		var from: String = "user://files/%s/%s" % [target_folder_path, target_folder_name]
		DirAccess.rename_absolute(from, to)
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path == to_path:
				instantiate_file_and_sort(file_manager, to_path)
	
	if target_folder != null:
		target_folder.get_parent().delete_file_with_name(target_folder_name)
	
	if to_path.is_empty():
		var desktop_file_manager: DesktopFileManager = get_tree().get_first_node_in_group("desktop_file_manager")
		instantiate_file_and_sort(desktop_file_manager, to_path)
	
	target_folder = null

func copy_directory_recursively(dir_path: String, to_path: String) -> void:
	if to_path.begins_with(dir_path):
		NotificationManager.spawn_notification("ERROR: Can't copy a folder into itself!")
		return
	for dir_name in DirAccess.get_directories_at(dir_path):
		DirAccess.make_dir_absolute("%s/%s" % [to_path, dir_name])
		copy_directory_recursively("%s/%s" % [dir_path, dir_name], "%s/%s" % [to_path, dir_name])
	for file_name in DirAccess.get_files_at(dir_path):
		DirAccess.copy_absolute("%s/%s" % [dir_path, file_name], "%s/%s" % [to_path, file_name])

func instantiate_file_and_sort(file_manager: BaseFileManager, to_path: String) -> void:
	if target_folder_type == FakeFolder.file_type_enum.FOLDER:
		file_manager.instantiate_file(target_folder_name, "%s/%s" % [to_path, target_folder_name], target_folder_type)
	else:
		file_manager.instantiate_file(target_folder_name, to_path, target_folder_type)
	file_manager.sort_folders()

func _handle_dropped_folders(files: PackedStringArray) -> void:
	for file_name: String in files:
		var extension: String = file_name.split(".")[-1]
		match extension:
			"txt", "md", "jpg", "jpeg", "png", "webp":
				var new_file_name: String
				if OS.has_feature("windows"):
					new_file_name = file_name.replace("\\", "/").split("/")[-1]
				else:
					new_file_name = file_name.split("/")[-1]
				DirAccess.copy_absolute(file_name, "user://files/%s" % new_file_name)
				get_tree().get_first_node_in_group("desktop_file_manager").populate_file_manager()
