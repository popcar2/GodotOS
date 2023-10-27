extends HFlowContainer

var file_path: String # Relative to user://files/

func _ready():
	populate_window()

func reload_window(folder_path: String):
	file_path = folder_path
	
	for child in get_children():
		child.queue_free()
	
	populate_window()
	
	#TODO make this less dumb
	$"../../Top Bar/Title Text".text = "[center]%s" % folder_path

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


func _on_back_button_pressed():
	#TODO move it to a position that's less stupid
	var split_path: PackedStringArray = file_path.split("/")
	if split_path.size() <= 1:
		return
	
	split_path.remove_at(split_path.size() - 1)
	file_path = "/".join(split_path)
	
	reload_window(file_path)
