extends VFlowContainer
class_name DesktopFileManager

# Desktop file manager

func _ready():
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("files"):
		# TODO add default files
		user_dir.make_dir("files")
	
	refresh_files()

func refresh_files():
	for child in get_children():
		if child is Control:
			child.queue_free()
	
	for folder_name: String in DirAccess.get_directories_at("user://files/"):
		var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
		folder.folder_path = folder_name
		folder.folder_name = folder_name
		add_child(folder)
	
	for file_name: String in DirAccess.get_files_at("user://files/"):
		if file_name.ends_with(".txt"):
			var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
			folder.folder_name = file_name
			folder.file_type = FakeFolder.file_type_enum.TEXT_FILE
			add_child(folder)
		elif file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg")\
		or file_name.ends_with(".webp"):
			var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
			folder.folder_name = file_name
			folder.file_type = FakeFolder.file_type_enum.IMAGE
			add_child(folder)

func new_folder():
	var new_folder_path: String = "user://files/New Folder"
	if DirAccess.dir_exists_absolute(new_folder_path):
		for i in range(2, 1000):
			new_folder_path = "user://files/New Folder %d" % i
			if !DirAccess.dir_exists_absolute(new_folder_path):
				break
	
	DirAccess.make_dir_absolute(new_folder_path)
	refresh_files()

func new_file(extension: String):
	var new_file_path: String = "user://files/New File%s" % extension
	
	if FileAccess.file_exists(new_file_path):
		for i in range(2, 1000):
			new_file_path = "user://files/New File %d%s" % [i, extension]
			if !FileAccess.file_exists(new_file_path):
				break
	
	# Just touches the file
	var _file: FileAccess = FileAccess.open(new_file_path, FileAccess.WRITE)
	refresh_files()
