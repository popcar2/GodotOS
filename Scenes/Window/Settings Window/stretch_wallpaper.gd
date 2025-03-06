extends OptionButton

## The wallpaper stretch options in the settings menu.

@onready var wallpaper: Wallpaper = $"/root/Control/Wallpaper"

func _ready() -> void:
	if !wallpaper:
		printerr("stretch_wallpaper.gd: Couldn't find wallpaper.")
		return
	
	if wallpaper.texture == null:
		disabled = true
	wallpaper.wallpaper_added.connect(_on_wallpaper_added)
	match DefaultValues.wallpaper_stretch_mode:
		0: selected = 0
		1: selected = 1
		5: selected = 2
		6: selected = 3

func _on_wallpaper_added() -> void:
	disabled = false

func _on_item_selected(index: int) -> void:
	if index == 0:
		# Scale mode
		wallpaper.apply_wallpaper_stretch_mode(TextureRect.STRETCH_SCALE)
	elif index == 1:
		#Tile
		wallpaper.apply_wallpaper_stretch_mode(TextureRect.STRETCH_TILE)
	elif index == 2:
		#Center
		wallpaper.apply_wallpaper_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	elif index == 3:
		#Covered
		wallpaper.apply_wallpaper_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_COVERED)
