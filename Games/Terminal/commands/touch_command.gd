extends TerminalCommand


func _init() -> void:
	call_name = "touch"


func execute(terminal: Terminal, args: Array[String]) -> void:
	if args.size() <= 0:
		terminal.push_line_to_output(
			"Expected more than 0 arguments"
		)
		return
	
	var current_path: String = terminal.virtual_path_manager.get_path()
	if current_path != "" and current_path[-1] != '/':
		current_path += '/'
	
	var desktop: DesktopFileManager = terminal.get_tree().get_first_node_in_group("desktop_file_manager")
	var files: PackedStringArray = terminal.virtual_path_manager.list_files()
	for file_name in args:
		if file_name.begins_with('.'):
			terminal.push_line_to_output("File %s starts with \".\", hidden files are not suported." % file_name)
			continue
		
		elif file_name.contains('/') or file_name.contains('\\'):
			terminal.push_line_to_output("File %s has a invalid name." % file_name)
			continue
		
		elif files.has(file_name):
			terminal.push_line_to_output("File %s already exists." % file_name)
			continue
		
		desktop.new_file(".txt", FakeFolder.file_type_enum.TEXT_FILE, file_name, current_path)


func usage() -> Array[String]:
	return [
		"Touch - Creates a new file in the current dir.",
		"USAGE:",
		"Takes one argument, the new .txt file name"
	]
