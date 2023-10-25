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
