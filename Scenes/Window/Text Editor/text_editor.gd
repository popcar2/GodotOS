extends TextEdit

var file: FileAccess

func populate_text(file_path: String):
	file = FileAccess.open("user://files/%s" % file_path, FileAccess.READ_WRITE)
	text = file.get_as_text()
