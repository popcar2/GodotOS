extends TerminalCommand


func _init() -> void:
	call_name = "cd"


func execute(terminal: Terminal, args: Array[String]) -> void:
	if args.size() > 1:
		terminal.push_line_to_output(
			"Invalid number of arguments, expected 1, found %s." % [args.size()]
		)
		return
	
	elif args.size() == 0:
		terminal.virtual_path_manager.set_path("")
		return
	
	var path_to: String = args[0].simplify_path()
	if path_to == "..":
		terminal.virtual_path_manager.set_path(
			terminal.virtual_path_manager.get_base_dir()
		)
		return
	
	var current_path: String = terminal.virtual_path_manager.get_path()
	if current_path != "" and current_path[-1] != '/':
		current_path += '/'
	
	var folder_path: String = current_path + path_to
	if terminal.virtual_path_manager.path_is_valid_folder(folder_path):
		terminal.virtual_path_manager.set_path(folder_path)
	else:
		terminal.push_line_to_output(folder_path + " do not exist or its a file.")


func usage() -> Array[String]:
	return [
		"Cd - Change directory.",
		"USAGE:",
		"Expects a valid path or nothing as argument.",
		"If no argument is given, change to root directory,",
		"If \"..\" is given, go up one directory,",
		"If a valid path is given, change to it.",
	]
