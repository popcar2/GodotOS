extends Node
## Copies and pastes folders and files

var target_folder: FakeFolder

enum StateEnum{COPY, CUT}
var state: StateEnum = StateEnum.COPY

func _ready() -> void:
	get_viewport().files_dropped.connect(_handle_dropped_folders)

func copy_folder(folder: FakeFolder) -> void:
	if target_folder:
		target_folder.modulate.a = 1
	target_folder = folder
	target_folder.modulate.a = 0.8
	state = StateEnum.COPY
	NotificationManager.spawn_notification("Copied [color=59ea90][wave freq=7]%s[/wave][/color]" % target_folder.folder_name)

func cut_folder(folder: FakeFolder) -> void:
	if target_folder:
		target_folder.modulate.a = 1
	target_folder = folder
	target_folder.modulate.a = 0.8
	state = StateEnum.CUT
	NotificationManager.spawn_notification("Cutting [color=59ea90][wave freq=7]%s[/wave][/color]" % target_folder.folder_name)

func paste_folder(to_path: String) -> void:
	if !target_folder:
		NotificationManager.spawn_notification("Error: Nothing to copy")
	
	if state == StateEnum.COPY:
		paste_folder_copy(to_path)
	elif state == StateEnum.CUT:
		paste_folder_cut(to_path)

func paste_folder_copy(to_path: String) -> void:
	var to: String = "user://files/%s/%s" % [to_path, target_folder.folder_name]
	if target_folder.file_type == FakeFolder.file_type_enum.FOLDER:
		var from: String = "user://files/%s" % target_folder.folder_path
		DirAccess.make_dir_absolute(to)
		copy_directory_recursively(from, to)
	else:
		var from: String = "user://files/%s/%s" % [target_folder.folder_path, target_folder.folder_name]
		DirAccess.copy_absolute(from, to)
	
	target_folder.modulate.a = 1
	if to_path.is_empty():
		var desktop_file_manager: DesktopFileManager = get_tree().get_first_node_in_group("desktop_file_manager")
		instantiate_file_and_sort(desktop_file_manager, to_path)
	else:
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path == to_path:
				instantiate_file_and_sort(file_manager, to_path)
	
	target_folder = null

func paste_folder_cut(to_path: String) -> void:
	var to: String = "user://files/%s/%s" % [to_path, target_folder.folder_name]
	if target_folder.file_type == FakeFolder.file_type_enum.FOLDER:
		var from: String = "user://files/%s" % target_folder.folder_path
		DirAccess.rename_absolute(from, to)
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path.begins_with(target_folder.folder_path):
				file_manager.close_window()
			elif file_manager.file_path == to_path:
				instantiate_file_and_sort(file_manager, to_path)
	else:
		var from: String = "user://files/%s/%s" % [target_folder.folder_path, target_folder.folder_name]
		DirAccess.rename_absolute(from, to)
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path == to_path:
				instantiate_file_and_sort(file_manager, to_path)
	
	target_folder.get_parent().delete_file_with_name(target_folder.folder_name)
	
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
	if target_folder.file_type == FakeFolder.file_type_enum.FOLDER:
		file_manager.instantiate_file(target_folder.folder_name, "%s/%s" % [to_path, target_folder.folder_name], target_folder.file_type)
	else:
		file_manager.instantiate_file(target_folder.folder_name, to_path, target_folder.file_type)
	file_manager.sort_folders()

func _handle_dropped_folders(files: PackedStringArray) -> void:
	for file_name: String in files:
		var extension: String = file_name.split(".")[-1]
		match extension:
			"txt", "md", "jpg", "jpeg", "png", "webp":
				DirAccess.copy_absolute(file_name, "user://files/%s" % file_name.split("/")[-1])
				get_tree().get_first_node_in_group("desktop_file_manager").populate_file_manager()
