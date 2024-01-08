extends Button

## The remove wallpaper button in the settings menu.

@onready var wallpaper: Wallpaper = $"/root/Control/Wallpaper"

func _ready() -> void:
	if !wallpaper:
		printerr("remove_wallpaper.gd: Couldn't find wallpaper (are you debugging the settings menu?)")
		return
	
	if wallpaper.texture == null:
		disabled = true
	wallpaper.wallpaper_added.connect(_on_wallpaper_added)

func _on_wallpaper_added() -> void:
	disabled = false

func _on_pressed() -> void:
	wallpaper.remove_wallpaper()
	disabled = true
