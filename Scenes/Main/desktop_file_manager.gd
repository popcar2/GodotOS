extends SmoothContainer
class_name DesktopFileManager

# Desktop file manager

func _ready():
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("files"):
		# TODO add default files
		user_dir.make_dir("files")
	
	refresh_files()
	
	get_window().size_changed.connect(update_positions)

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
	
	await get_tree().physics_frame
	update_positions()

func new_folder():
	var new_folder_name: String = "New Folder"
	if DirAccess.dir_exists_absolute("user://files/%s" % new_folder_name):
		for i in range(2, 1000):
			new_folder_name = "New Folder %d" % i
			if !DirAccess.dir_exists_absolute("user://files/%s" % new_folder_name):
				break
	
	DirAccess.make_dir_absolute("user://files/%s" % new_folder_name)
	instantiate_file(new_folder_name, "user://files/", FakeFolder.file_type_enum.FOLDER, true)
	await get_tree().process_frame # Waiting for child to get moved...
	update_positions()

func new_file(extension: String, file_type: FakeFolder.file_type_enum):
	var new_file_name: String = "New File%s" % extension
	
	if FileAccess.file_exists("user://files/%s" % new_file_name):
		for i in range(2, 1000):
			new_file_name = "New File %d%s" % [i, extension]
			if !FileAccess.file_exists("user://files/%s" % new_file_name):
				break
	
	# Just touches the file
	var _file: FileAccess = FileAccess.open("user://files/%s" % new_file_name, FileAccess.WRITE)
	instantiate_file(new_file_name, "user://files/", file_type, true)
	await get_tree().process_frame # Waiting for child to get moved...
	update_positions()

func instantiate_file(file_name: String, path: String, file_type: FakeFolder.file_type_enum, sort: bool = false):
	var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
	folder.folder_name = file_name
	folder.folder_path = path
	folder.file_type = file_type
	add_child(folder)
	
	if sort:
		await get_tree().process_frame
		sort_file(folder)

func sort_file(folder: FakeFolder):
	var final_index: int = -1
	for child in get_children():
		if !(child is FakeFolder) or child.file_type != folder.file_type:
			continue
		if child.folder_name < folder.folder_name:
			final_index = child.get_index() + 1
	
	move_child(folder, final_index)
