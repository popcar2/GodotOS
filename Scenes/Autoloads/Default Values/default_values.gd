extends Node
## Sets some default values on startup and handles saving/loading user preferences

var wallpaper_name: String
@onready var background_color_rect: ColorRect = $"/root/Control/BackgroundColor"
@onready var wallpaper: Wallpaper = $"/root/Control/Wallpaper"

func _ready():
	DisplayServer.window_set_min_size(Vector2i(600, 525))
	
	if FileAccess.file_exists("user://user_preferences.txt"):
		load_state()
	else:
		save_state()

func save_state():
	var save_dict: Dictionary = {
		"wallpaper_name": wallpaper_name,
		"background_color": background_color_rect.color.to_html(),
		"zoom_level": get_window().content_scale_factor
	}
	
	var json_string: String = JSON.stringify(save_dict)
	
	var save_file: FileAccess = FileAccess.open("user://user_preferences.txt", FileAccess.WRITE)
	save_file.store_line(json_string)

func load_state():
	var save_file: FileAccess = FileAccess.open("user://user_preferences.txt", FileAccess.READ)
	
	var json_string: String = save_file.get_line()
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != OK:
		printerr("default_values.gd: Failed to parse user preferences file!")
		return
	
	var save_dict: Dictionary = json.get_data()
	
	wallpaper_name = save_dict.wallpaper_name
	if !wallpaper_name.is_empty():
		wallpaper.apply_wallpaper_from_path(wallpaper_name)
	
	background_color_rect.color = Color.from_string(save_dict.background_color, Color8(77, 77, 77))
	get_window().content_scale_factor = save_dict.zoom_level

func save_wallpaper(wallpaper_file: FakeFolder):
	delete_wallpaper()
	
	var from: String = "user://files/%s/%s" % [wallpaper_file.folder_path, wallpaper_file.folder_name]
	var to: String = "user://%s" % wallpaper_file.folder_name
	DirAccess.copy_absolute(from, to)
	wallpaper_name = wallpaper_file.folder_name
	save_state()

func delete_wallpaper():
	if !wallpaper_name.is_empty():
		DirAccess.remove_absolute("user://%s" % wallpaper_name)
	wallpaper_name = ""
	save_state()
