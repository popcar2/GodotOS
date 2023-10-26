extends TextEdit

var text_edited: bool
var file_path: String

func _input(event: InputEvent):
	if !$"../..".is_selected:
		return
	
	if event.is_action_pressed("save"):
		save_file()

func populate_text(path: String):
	file_path = path
	var file: FileAccess = FileAccess.open("user://files/%s" % file_path, FileAccess.READ)
	text = file.get_as_text()

func _on_text_changed():
	if text_edited:
		return
	
	text_edited = true
	$"../../Top Bar/Title Text".text += '*' 

func save_file():
	var file: FileAccess = FileAccess.open("user://files/%s" % file_path, FileAccess.WRITE)
	file.store_string(text)
	
	$"../../Top Bar/Title Text".text = $"../../Top Bar/Title Text".text.trim_suffix('*')
	text_edited = false
	
	var saved_notification: Panel = load("res://Scenes/Window/Text Editor/saved_notification.tscn").instantiate()
	saved_notification.global_position.y = global_position.y + size.y - saved_notification.size.y
	saved_notification.global_position.x = global_position.x + size.x - saved_notification.size.x
	get_tree().current_scene.add_child(saved_notification)
	#TODO make this a parent child?

#TODO add warning when someone exits without saving
