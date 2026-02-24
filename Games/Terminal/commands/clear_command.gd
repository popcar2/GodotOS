extends TerminalCommand


func _init() -> void:
	call_name = "clear"


func execute(terminal: Terminal, args: Array[String]) -> void:
	if args.size() > 0:
		terminal.push_line_to_output(
			"Invalid number of arguments, expected 0, found %s." % [args.size()]
		)
		return
	
	terminal.clear_output()


func usage() -> Array[String]:
	return [
		"Clear - Clear screen.",
		"USAGE:",
		"Takes no arguments.",
		"queue_free all lines to clear screen, emptying the output history."
	]
