extends SmoothContainer
class_name BaseFileManager

@export var file_path: String # Relative to user://files/

func populate_file_manager():
	for child in get_children():
		if child is FakeFolder:
			child.queue_free()
	for folder_name in DirAccess.get_directories_at("user://files/%s" % file_path):
		if file_path.is_empty():
			instantiate_file(folder_name, folder_name, FakeFolder.file_type_enum.FOLDER)
		else:
			instantiate_file(folder_name, "%s/%s" % [file_path, folder_name], FakeFolder.file_type_enum.FOLDER)
	
	for file_name: String in DirAccess.get_files_at("user://files/%s" % file_path):
		if file_name.ends_with(".txt"):
			instantiate_file(file_name, file_path, FakeFolder.file_type_enum.TEXT_FILE)
		elif file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg")\
		or file_name.ends_with(".webp"):
			instantiate_file(file_name, file_path, FakeFolder.file_type_enum.IMAGE)
	
	await get_tree().process_frame
	await get_tree().process_frame # TODO fix whatever's causing a race condition :/
	sort_folders()

func instantiate_file(file_name: String, path: String, file_type: FakeFolder.file_type_enum):
	var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
	folder.folder_name = file_name
	folder.folder_path = path
	folder.file_type = file_type
	add_child(folder)

func sort_folders():
	if len(get_children()) < 3:
		update_positions(false)
		return
	var sorted_children: Array[Node] = []
	for child in get_children():
		if child is FakeFolder:
			sorted_children.append(child)
			remove_child(child)
	sorted_children.sort_custom(_custom_folder_sort)
	sorted_children.sort_custom(_custom_folders_first_sort)
	for child in sorted_children:
		add_child(child)
	
	await get_tree().process_frame
	update_positions(false)

func new_folder():
	var new_folder_name: String = "New Folder"
	var padded_file_path: String # Since I sometimes want the / and sometimes not
	if !file_path.is_empty():
		padded_file_path = "%s/" % file_path
	if DirAccess.dir_exists_absolute("user://files/%s%s" % [padded_file_path, new_folder_name]):
		for i in range(2, 1000):
			new_folder_name = "New Folder %d" % i
			if !DirAccess.dir_exists_absolute("user://files/%s%s" % [padded_file_path, new_folder_name]):
				break
	
	DirAccess.make_dir_absolute("user://files/%s%s" % [padded_file_path, new_folder_name])
	for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
		if file_manager.file_path == file_path:
			file_manager.instantiate_file(new_folder_name, "%s%s" % [padded_file_path, new_folder_name], FakeFolder.file_type_enum.FOLDER)
			await get_tree().process_frame # Waiting for child to get added...
			sort_folders()
	
	if file_path.is_empty():
		instantiate_file(new_folder_name, "%s" % new_folder_name, FakeFolder.file_type_enum.FOLDER)
		sort_folders()


func new_file(extension: String, file_type: FakeFolder.file_type_enum):
	var new_file_name: String = "New File%s" % extension
	var padded_file_path: String # Since I sometimes want the / and sometimes not
	if !file_path.is_empty():
		padded_file_path = "%s/" % file_path
	
	if FileAccess.file_exists("user://files/%s%s" % [padded_file_path, new_file_name]):
		for i in range(2, 1000):
			new_file_name = "New File %d%s" % [i, extension]
			if !FileAccess.file_exists("user://files/%s%s" % [padded_file_path, new_file_name]):
				break
	
	# Just touches the file
	var _file: FileAccess = FileAccess.open("user://files/%s%s" % [padded_file_path, new_file_name], FileAccess.WRITE)
	
	for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
		if file_manager.file_path == file_path:
			file_manager.instantiate_file(new_file_name, file_path, file_type)
			await get_tree().process_frame # Waiting for child to get added...
			file_manager.sort_folders()
	
	if file_path.is_empty():
		instantiate_file(new_file_name, file_path, file_type)
		sort_folders()

func delete_file_with_name(file_name: String):
	for child in get_children():
		if !(child is FakeFolder):
			continue
		
		if child.folder_name == file_name:
			child.queue_free()
	
	await get_tree().process_frame
	sort_folders()

## Sorts folders based on their name
func _custom_folder_sort(a: FakeFolder, b: FakeFolder):
	if a.folder_name.to_lower() < b.folder_name.to_lower():
		return true
	return false

## Puts folders first in the array
func _custom_folders_first_sort(a: FakeFolder, b: FakeFolder):
	if a.file_type == FakeFolder.file_type_enum.FOLDER and a.file_type != b.file_type:
		return true
	return false
