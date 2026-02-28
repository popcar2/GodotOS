extends TerminalCommand


func _init() -> void:
	call_name = "help"


func execute(terminal: Terminal, args: Array[String]) -> void:
	if args.size() > 1:
		terminal.push_line_to_output(
			"Invalid number of arguments, expected 1, found %s." % [args.size()]
		)
		return
	
	if args.size() == 0:
		terminal.push_lines_to_output(usage())
		terminal.push_line_to_output("")
		
		var commands: Array[String] = terminal.command_manager.get_command_call_names()
		commands.sort_custom(
			func(a: String, b: String) -> bool:
				return a.length() < b.length()
		)# Sort by call_name size
		for cmd_name: String in commands:
			terminal.push_line_to_output(cmd_name)
		
		return
	
	var command_call_name: String = args[0]
	if !terminal.command_manager.cmd_exists(command_call_name):
		terminal.push_line_to_output("%s not found." % [command_call_name])
		return
	
	terminal.push_lines_to_output(
		terminal.command_manager.load_command(command_call_name).usage()
	)


func usage() -> Array[String]:
	return [
		"Help - Prints a command usage information.",
		"USAGE:",
		"Takes zero or one argument.",
		"If no argument is given show the usage and the list of commands.",
		"If given argument is a valid command call_name",
		"push it's usage info line by line to the terminal."
	]
