extends TerminalCommand


func _init() -> void:
	call_name = "touch"


func execute(terminal: Terminal, args: Array[String]) -> void:
	if args.size() == 0 or args.size() > 1:
		terminal.push_line_to_output(
			"Invalid number of arguments, expected 1, found %s." % [args.size()]
		)
		return
	
	var current_path: String = terminal.virtual_path_manager.get_path()
	if current_path != "" and current_path[-1] != '/':
		current_path += '/'
	
	var file_name: String = args[0]
	
	var desktop: DesktopFileManager = terminal.get_tree().get_first_node_in_group("desktop_file_manager")
	desktop.new_file(".txt", FakeFolder.file_type_enum.TEXT_FILE, file_name, current_path)


func usage() -> Array[String]:
	return [
		"Touch - Creates a new file in the current dir.",
		"USAGE:",
		"Takes one argument, the new .txt file name"
	]
