extends BaseFileManager
class_name FileManagerWindow

## The file manager window.

func _ready() -> void:
	populate_file_manager()
	sort_folders()
	
	$"../../Resize Drag Spot".window_resized.connect(update_positions)

func reload_window(folder_path: String) -> void:
	# Reload the same path if not given folder_path
	if !folder_path.is_empty():
		file_path = folder_path
	
	for child in get_children():
		if child is FakeFolder:
			child.queue_free()
	
	populate_file_manager()
	
	#TODO make this less dumb
	$"../../Top Bar/Title Text".text = "[center]%s" % file_path

func close_window() -> void:
	$"../.."._on_close_button_pressed()

## Goes to the folder above the currently shown one. Can't go higher than user://files/
func _on_back_button_pressed() -> void:
	#TODO move it to a position that's less stupid
	var split_path: PackedStringArray = file_path.split("/")
	if split_path.size() <= 1:
		return
	
	split_path.remove_at(split_path.size() - 1)
	file_path = "/".join(split_path)
	
	reload_window(file_path)
