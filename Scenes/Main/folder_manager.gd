extends VFlowContainer

func _ready():
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("files"):
		user_dir.make_dir("files")
	
	for folder_name in DirAccess.get_directories_at("user://files/"):
		var folder: Control = load("res://Scenes/Desktop/folder.tscn").instantiate()
		folder.folder_name = folder_name
		add_child(folder)
