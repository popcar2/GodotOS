extends Node
## Sets some default values on startup and handles saving/loading user preferences

var wallpaper_name: String
@onready var background_color_rect: ColorRect = $"/root/Control/BackgroundColor"
@onready var wallpaper: Wallpaper = $"/root/Control/Wallpaper"

func _ready() -> void:
	DisplayServer.window_set_min_size(Vector2i(600, 525))
	
	#NOTE: Vsync is disabled due to input lag: https://github.com/godotengine/godot/issues/75830
	#NOTE: Web can't get screen refresh rate
	var new_max_fps: int = int(DisplayServer.screen_get_refresh_rate())
	if new_max_fps == -1:
		Engine.max_fps = 60
	else:
		Engine.max_fps = new_max_fps
	
	
	if wallpaper == null or background_color_rect == null:
		printerr("default_values.gd: Couldn't find wallpaper (are you debugging a scene?)")
		return
	
	if FileAccess.file_exists("user://user_preferences.txt"):
		load_state()
	else:
		save_state()

func save_state() -> void:
	var save_dict: Dictionary = {
		"wallpaper_name": wallpaper_name,
		"background_color": background_color_rect.color.to_html(),
		"zoom_level": get_window().content_scale_factor
	}
	
	var json_string: String = JSON.stringify(save_dict)
	
	var save_file: FileAccess = FileAccess.open("user://user_preferences.txt", FileAccess.WRITE)
	save_file.store_line(json_string)

func load_state() -> void:
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

## Copies the wallpaper to root GodotOS folder so it can load it again later. 
## It doesn't use the actual wallpaper file since it can be removed/deleted.
func save_wallpaper(wallpaper_file: FakeFolder) -> void:
	delete_wallpaper()
	
	var from: String = "user://files/%s/%s" % [wallpaper_file.folder_path, wallpaper_file.folder_name]
	var to: String = "user://%s" % wallpaper_file.folder_name
	DirAccess.copy_absolute(from, to)
	wallpaper_name = wallpaper_file.folder_name
	save_state()

func delete_wallpaper() -> void:
	if !wallpaper_name.is_empty():
		DirAccess.remove_absolute("user://%s" % wallpaper_name)
	wallpaper_name = ""
	save_state()
