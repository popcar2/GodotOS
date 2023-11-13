extends HFlowContainer
class_name FileManagerWindow

var file_path: String # Relative to user://files/

func _ready():
	populate_window()

func reload_window(folder_path: String):
	# Reload the same path if not given folder_path
	if !folder_path.is_empty():
		file_path = folder_path
	
	for child in get_children():
		if child is Control:
			child.queue_free()
	
	populate_window()
	
	#TODO make this less dumb
	$"../../Top Bar/Title Text".text = "[center]%s" % file_path

func populate_window():
	for folder_name in DirAccess.get_directories_at("user://files/%s" % file_path):
		var folder: Control = load("res://Scenes/Desktop/folder.tscn").instantiate()
		folder.folder_name = folder_name
		folder.folder_path = "%s/%s" % [file_path, folder_name]
		folder.scale = Vector2(0.75, 0.75)
		add_child(folder)
	
	for file_name: String in DirAccess.get_files_at("user://files/%s" % file_path):
		if file_name.ends_with(".txt"):
			var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
			folder.folder_name = file_name
			folder.folder_path = file_path
			folder.file_type = FakeFolder.file_type_enum.TEXT_FILE
			add_child(folder)
		elif file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg")\
		or file_name.ends_with(".webp"):
			var folder: FakeFolder = load("res://Scenes/Desktop/folder.tscn").instantiate()
			folder.folder_name = file_name
			folder.folder_path = file_path
			folder.file_type = FakeFolder.file_type_enum.IMAGE
			add_child(folder)

func new_folder():
	var new_folder_path: String = "user://files/%s/New Folder" % file_path
	if DirAccess.dir_exists_absolute(new_folder_path):
		for i in range(2, 1000):
			new_folder_path = "user://files/%s/New Folder %d" % [file_path, i]
			if !DirAccess.dir_exists_absolute(new_folder_path):
				break
	
	DirAccess.make_dir_absolute(new_folder_path)
	reload_window("")

func new_file(extension: String):
	var new_file_path: String = "user://files/%s/New File%s" % [file_path, extension]
	
	if FileAccess.file_exists(new_file_path):
		for i in range(2, 1000):
			new_file_path = "user://files/%s/New File %d%s" % [file_path, i, extension]
			if !FileAccess.file_exists(new_file_path):
				break
	
	# Just touches the file
	var _file: FileAccess = FileAccess.open(new_file_path, FileAccess.WRITE)
	reload_window("")

func _on_back_button_pressed():
	#TODO move it to a position that's less stupid
	var split_path: PackedStringArray = file_path.split("/")
	if split_path.size() <= 1:
		return
	
	split_path.remove_at(split_path.size() - 1)
	file_path = "/".join(split_path)
	
	reload_window(file_path)
