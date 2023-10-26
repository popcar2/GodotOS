extends TextEdit

var file: FileAccess
var text_edited: bool

func populate_text(file_path: String):
	file = FileAccess.open("user://files/%s" % file_path, FileAccess.READ_WRITE)
	text = file.get_as_text()

func _on_text_changed():
	if text_edited:
		return
	
	text_edited = true
	$"../../Top Bar/Title Text".text += '*' 

#TODO save with ctrl+s
