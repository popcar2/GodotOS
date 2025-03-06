extends BaseFileManager
class_name DesktopFileManager

## The desktop file manager.

func _ready() -> void:
	var user_dir: DirAccess = DirAccess.open("user://")
	if !user_dir.dir_exists("files"):
		# Can't just use absolute paths due to https://github.com/godotengine/godot/issues/82550
		# Also DirAccess can't open on res:// at export, but FileAccess does...
		user_dir.make_dir_recursive("files/Welcome Folder")
		user_dir.make_dir_recursive("files/Wallpapers")
		copy_from_res("res://Default Files/Welcome.txt", "user://files/Welcome Folder/Welcome.txt")
		copy_from_res("res://Default Files/Credits.txt", "user://files/Welcome Folder/Credits.txt")
		copy_from_res("res://Default Files/GodotOS Handbook.txt", "user://files/Welcome Folder/GodotOS Handbook.txt")
		copy_from_res("res://Default Files/default wall.webp", "user://files/default wall.webp")
		
		#Additional wallpapers
		copy_from_res("res://Default Files/wallpaper_chill.png", "user://files/Wallpapers//chill.png")
		copy_from_res("res://Default Files/wallpaper_minimalism.png", "user://files/Wallpapers//minimalism.png")
		copy_from_res("res://Default Files/wallpaper_mosaic.png", "user://files/Wallpapers/mosaic.png")
		
		var wallpaper: Wallpaper = $"/root/Control/Wallpaper"
		wallpaper.apply_wallpaper_from_path("files/default wall.webp")
		
		copy_from_res("res://Default Files/default wall.webp", "user://default wall.webp")
		DefaultValues.wallpaper_name = "default wall.webp"
		DefaultValues.save_state()
	
	populate_file_manager()
	get_window().size_changed.connect(update_positions)
	get_window().focus_entered.connect(_on_window_focus)

func copy_from_res(from: String, to: String) -> void:
	var file_from: FileAccess = FileAccess.open(from, FileAccess.READ)
	var file_to: FileAccess = FileAccess.open(to, FileAccess.WRITE)
	file_to.store_buffer(file_from.get_buffer(file_from.get_length()))
	
	file_from.close()
	file_to.close()

## Checks if any files were changed on the desktop, and populates the file manager again if so.
func _on_window_focus() -> void:
	var current_file_names: Array[String] = []
	for child in get_children():
		if !(child is FakeFolder):
			continue
		
		current_file_names.append(child.folder_name)
	
	var new_file_names: Array[String] = []
	for file_name in DirAccess.get_files_at("user://files/"):
		new_file_names.append(file_name)
	for folder_name in DirAccess.get_directories_at("user://files/"):
		new_file_names.append(folder_name)
	
	if current_file_names.size() != new_file_names.size():
		populate_file_manager()
		return
	
	for file_name in new_file_names:
		if !current_file_names.has(file_name):
			populate_file_manager()
			return
