extends SmoothContainer
class_name FileManagerWindow

var file_path: String # Relative to user://files/

func _ready():
	populate_window()
	$"../../Resize Drag Spot".window_resized.connect(update_positions)

func reload_window(folder_path: String):
	# Reload the same path if not given folder_path
	if !folder_path.is_empty():
		file_path = folder_path
	
	for child in get_children():
		if child is FakeFolder:
			child.queue_free()
	
	populate_window()
	
	#TODO make this less dumb
	$"../../Top Bar/Title Text".text = "[center]%s" % file_path

func populate_window():
	for folder_name in DirAccess.get_directories_at("user://files/%s" % file_path):
		instantiate_file(folder_name, "%s/%s" % [file_path, folder_name], FakeFolder.file_type_enum.FOLDER)
	
	for file_name: String in DirAccess.get_files_at("user://files/%s" % file_path):
		if file_name.ends_with(".txt"):
			instantiate_file(file_name, file_path, FakeFolder.file_type_enum.TEXT_FILE)
		elif file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg")\
		or file_name.ends_with(".webp"):
			instantiate_file(file_name, file_path, FakeFolder.file_type_enum.IMAGE)
	
	await get_tree().process_frame
	await get_tree().process_frame # TODO fix whatever's causing a race condition :/
	update_positions()

func instantiate_file(file_name: String, path: String, file_type: FakeFolder.file_type_enum, sort: bool = false):
	var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
	folder.folder_name = file_name
	folder.folder_path = path
	folder.file_type = file_type
	add_child(folder)
	
	if !sort:
		return
	
	var final_index: int = -1
	for child in get_children():
		if !(child is FakeFolder) or !(child.file_type == file_type):
			continue
		if child.folder_name < file_name:
			final_index = child.get_index() + 1
	
	await get_tree().process_frame
	move_child(folder, final_index)

func new_folder():
	var new_folder_name: String = "New Folder"
	if DirAccess.dir_exists_absolute("user://files/%s/%s" % [file_path, new_folder_name]):
		for i in range(2, 1000):
			new_folder_name = "New Folder %d" % i
			if !DirAccess.dir_exists_absolute("user://files/%s/%s" % [file_path, new_folder_name]):
				break
	
	DirAccess.make_dir_absolute("user://files/%s/%s" % [file_path, new_folder_name])
	for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
		if file_manager.file_path == file_path:
			file_manager.instantiate_file(new_folder_name, "%s/%s" % [file_path, new_folder_name], FakeFolder.file_type_enum.FOLDER, true)
			await get_tree().process_frame # Waiting for child to get moved...
			file_manager.update_positions()
	

func new_file(extension: String, file_type: FakeFolder.file_type_enum):
	var new_file_name: String = "New File%s" % extension
	
	if FileAccess.file_exists("user://files/%s/%s" % [file_path, new_file_name]):
		for i in range(2, 1000):
			new_file_name = "New File %d%s" % [i, extension]
			if !FileAccess.file_exists("user://files/%s/%s" % [file_path, new_file_name]):
				break
	
	# Just touches the file
	var _file: FileAccess = FileAccess.open("user://files/%s/%s" % [file_path, new_file_name], FileAccess.WRITE)
	
	for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
		if file_manager.file_path == file_path:
			file_manager.instantiate_file(new_file_name, "%s/%s" % [file_path, new_file_name], file_type, true)
			await get_tree().process_frame # Waiting for child to get moved...
			file_manager.update_positions()

func delete_file_with_name(file_name: String):
	for child in get_children():
		if !(child is FakeFolder):
			continue
		
		if child.folder_name == file_name:
			child.queue_free()

func close_window():
	$"../.."._on_close_button_pressed()

func _on_back_button_pressed():
	#TODO move it to a position that's less stupid
	var split_path: PackedStringArray = file_path.split("/")
	if split_path.size() <= 1:
		return
	
	split_path.remove_at(split_path.size() - 1)
	file_path = "/".join(split_path)
	
	reload_window(file_path)
