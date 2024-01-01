extends TextureRect

func import_image(file_path: String) -> void:
	var image: Image = Image.load_from_file("user://files/%s" % file_path)
	image.generate_mipmaps()
	var texture_import: ImageTexture = ImageTexture.create_from_image(image)
	texture = texture_import
