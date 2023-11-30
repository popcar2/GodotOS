extends Node

## Copies and pastes folders and files

var target_folder: FakeFolder

func copy_folder(folder: FakeFolder):
	if target_folder:
		target_folder.modulate.a = 1
	target_folder = folder
	target_folder.modulate.a = 0.8
	NotificationManager.spawn_notification("Copied [color=59ea90][wave freq=7]%s[/wave][/color]" % target_folder.folder_name)

func paste_folder(to_path: String):
	if !target_folder:
		NotificationManager.spawn_notification("Error: Nothing to copy")
	
	if target_folder.file_type == FakeFolder.file_type_enum.FOLDER:
		DirAccess.make_dir_absolute("user://files/%s/%s" % [to_path, target_folder.folder_name])
		copy_directory_recursively("user://files/%s" % target_folder.folder_path, "user://files/%s/%s" % [to_path, target_folder.folder_name])
	else:
		var from: String = "user://files/%s/%s" % [target_folder.folder_path, target_folder.folder_name]
		var to: String = "user://files/%s/%s" % [to_path, target_folder.folder_name]
		DirAccess.copy_absolute(from, to)
	
	target_folder.modulate.a = 1
	target_folder = null
	for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
		if file_manager.file_path == to_path:
			file_manager.populate_file_manager()

func copy_directory_recursively(dir_path: String, to_path: String):
	for file_name in DirAccess.get_files_at(dir_path):
		DirAccess.copy_absolute("%s/%s" % [dir_path, file_name], "%s/%s" % [to_path, file_name])
	for dir_name in DirAccess.get_directories_at(dir_path):
		DirAccess.make_dir_absolute("%s/%s" % [to_path, dir_name])
		copy_directory_recursively("%s/%s" % [dir_path, dir_name], "%s/%s" % [to_path, dir_name])
