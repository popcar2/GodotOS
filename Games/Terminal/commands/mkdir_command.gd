extends TerminalCommand


func _init() -> void:
	call_name = "mkdir"


func execute(terminal: Terminal, args: Array[String]) -> void:
	if args.size() <= 0:
		terminal.push_line_to_output(
			"Expected more than 0 arguments"
		)
		return
	
	var desktop: DesktopFileManager = terminal.get_tree().get_first_node_in_group("desktop_file_manager")
	var dirs: PackedStringArray = terminal.virtual_path_manager.list_directories()
	for folder_name: String in args:
		if folder_name.begins_with('.'):
			terminal.push_line_to_output("Folder %s starts with \".\", hidden folders are not suported." % folder_name)
			continue
		
		elif folder_name.contains('/') or folder_name.contains('\\'):
			terminal.push_line_to_output("Folder %s has a invalid name." % folder_name)
			continue
		
		elif dirs.has(folder_name):
			terminal.push_line_to_output("Folder %s already exists." % folder_name)
			continue
		
		desktop.new_folder(folder_name, terminal.virtual_path_manager.get_path())


func usage() -> Array[String]:
	return [
		"Mkdir - Make directory(ies).",
		"USAGE:",
		"Takes a arbitrary number of folder names as arguments.",
		"Creates a new folder in the current path for each given folder name."
	]
