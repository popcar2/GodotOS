extends TextureRect

func _ready():
	# I use a node to fade because fading modulate doesn't work if there is no texture
	$Fade.modulate.a = 0
	$Fade.visible = true

## Applies wallpaper from an image file
func apply_wallpaper_from_file(image_file: FakeFolder):
	var image: Image = Image.load_from_file("user://files/%s/%s" % [image_file.folder_path, image_file.folder_name])
	image.generate_mipmaps()
	var texture_import = ImageTexture.create_from_image(image)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	await tween.tween_property($Fade, "modulate:a", 1, 0.5).finished
	
	texture = texture_import
	
	var tween2: Tween = create_tween()
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property($Fade, "modulate:a", 0, 0.5)
