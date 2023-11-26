extends BaseFileManager
class_name DesktopFileManager

# Desktop file manager

func _ready():
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("files"):
		# Can't just use absolute paths due to https://github.com/godotengine/godot/issues/82550
		# Also DirAccess can't open on res:// at export, but FileAccess does...
		user_dir.make_dir_recursive("files/Welcome Folder")
		copy_from_res("res://Default Files/Welcome.txt", "user://files/Welcome.txt")
		copy_from_res("res://Default Files/Credits.txt", "user://files/Welcome Folder/Credits.txt")
	
	populate_file_manager()
	get_window().size_changed.connect(update_positions)

func copy_from_res(from: String, to: String):
	var file_from: FileAccess = FileAccess.open(from, FileAccess.READ)
	var file_to: FileAccess = FileAccess.open(to, FileAccess.WRITE)
	file_to.store_buffer(file_from.get_buffer(file_from.get_length()))
	
	file_from.close()
	file_to.close()
