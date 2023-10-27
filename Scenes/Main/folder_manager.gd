extends VFlowContainer

# Desktop file manager

func _ready():
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("files"):
		user_dir.make_dir("files")
	
	for folder_name: String in DirAccess.get_directories_at("user://files/"):
		var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
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
