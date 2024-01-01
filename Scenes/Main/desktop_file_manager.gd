extends BaseFileManager
class_name DesktopFileManager

# Desktop file manager

func _ready() -> void:
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("files"):
		# Can't just use absolute paths due to https://github.com/godotengine/godot/issues/82550
		# Also DirAccess can't open on res:// at export, but FileAccess does...
		user_dir.make_dir_recursive("files/Welcome Folder")
		copy_from_res("res://Default Files/Welcome.txt", "user://files/Welcome.txt")
		copy_from_res("res://Default Files/Credits.txt", "user://files/Welcome Folder/Credits.txt")
	
	populate_file_manager()
	get_window().size_changed.connect(update_positions)
	get_window().focus_entered.connect(_on_window_focus)

func copy_from_res(from: String, to: String) -> void:
	var file_from: FileAccess = FileAccess.open(from, FileAccess.READ)
	var file_to: FileAccess = FileAccess.open(to, FileAccess.WRITE)
	file_to.store_buffer(file_from.get_buffer(file_from.get_length()))
	
	file_from.close()
	file_to.close()

## Checks if any files were changed on the desktop, and populates the file manager again if so.
func _on_window_focus() -> void:
	var current_file_names: Array[String] = []
	for child in get_children():
		if !(child is FakeFolder):
			continue
		
		current_file_names.append(child.folder_name)
	
	var new_file_names: Array[String] = []
	for file_name in DirAccess.get_files_at("user://files/"):
		new_file_names.append(file_name)
	for folder_name in DirAccess.get_directories_at("user://files/"):
		new_file_names.append(folder_name)
	
	if current_file_names.size() != new_file_names.size():
		populate_file_manager()
		return
	
	for file_name in new_file_names:
		if !current_file_names.has(file_name):
			populate_file_manager()
			return
