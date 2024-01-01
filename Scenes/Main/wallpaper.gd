extends TextureRect
class_name Wallpaper

signal wallpaper_added()

func _ready() -> void:
	# I use a node to fade because fading modulate doesn't work if there is no texture
	$Fade.modulate.a = 0
	$Fade.visible = true

## Applies wallpaper from path (called from default_values.gd on start)
func apply_wallpaper_from_path(path: String) -> void:
	wallpaper_added.emit()
	
	var image: Image = Image.load_from_file("user://files/%s" % path)
	add_wallpaper(image)

## Applies wallpaper from an image file
func apply_wallpaper_from_file(image_file: FakeFolder) -> void:
	wallpaper_added.emit()
	DefaultValues.save_wallpaper(image_file)
	
	var image: Image = Image.load_from_file("user://files/%s/%s" % [image_file.folder_path, image_file.folder_name])
	add_wallpaper(image)

func add_wallpaper(image: Image) -> void:
	image.generate_mipmaps()
	var texture_import: ImageTexture = ImageTexture.create_from_image(image)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	await tween.tween_property($Fade, "modulate:a", 1, 0.5).finished
	
	texture = texture_import
	
	var tween2: Tween = create_tween()
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property($Fade, "modulate:a", 0, 0.5)

func remove_wallpaper() -> void:
	DefaultValues.delete_wallpaper()
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	await tween.tween_property($Fade, "modulate:a", 1, 0.5).finished
	
	texture = null
	
	var tween2: Tween = create_tween()
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property($Fade, "modulate:a", 0, 0.5)
