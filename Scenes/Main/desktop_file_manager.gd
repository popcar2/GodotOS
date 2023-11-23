extends BaseFileManager
class_name DesktopFileManager

# Desktop file manager

func _ready():
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("files"):
		# TODO add default files
		user_dir.make_dir("files")
	
	populate_file_manager()
	
	get_window().size_changed.connect(update_positions)

