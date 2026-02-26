extends Control
class_name Terminal


const COMMAND_OUTPUT_LABEL_SCENE: PackedScene = preload("res://Games/Terminal/src/command_output_label/command_output_label.tscn")

@onready var command_line: LineEdit = %command_line
@onready var command_output_container: VBoxContainer = %command_output_container
@onready var scroll_container: ScrollContainer = %scroll_container
@onready var path_indicator_label: Label = %path_indicator_label

@onready var command_manager := CommandManager.new()
@onready var input_parser := InputParser.new()
@onready var input_history_manager := InputHistoryManager.new(command_line)
@onready var virtual_path_manager := VirtualPathManager.new()


func _ready() -> void:
	# updates the label that indicates the current path when virtual path changes
	virtual_path_manager.on_virtual_path_changes.connect(
		func(_new_virt_path: String) -> void:
			path_indicator_label.text = virtual_path_manager.get_current_folder() + " > "
	)
	
	# Set initial virtual_path
	# Check for focused folder icon first
	if ContextMenu.target is FakeFolder:
		virtual_path_manager.set_path(ContextMenu.target.folder_path)
	# Check for a focused folder window to be the starting path
	elif ContextMenu.target is FileManagerWindow:
		var path: String = ContextMenu.target.file_path
		
		if virtual_path_manager.path_is_valid_folder(path):
			virtual_path_manager.set_path(path)
	
	# command_line focus follows window focus
	var parent_window: FakeWindow = find_parent_window()
	if parent_window != null:
		parent_window.selected.connect(
			func(is_selected: bool) -> void:
				if is_selected:
					command_line.call_deferred("grab_focus")
				else:
					command_line.call_deferred("release_focus")
		)


func _input(event: InputEvent) -> void:
	# command_line focus whenever the user clicks the window
	if event is InputEventMouseButton and event.is_pressed():
		command_line.grab_focus()


# Create and append a new CommandOutputLabel to the container
func push_line_to_output(text: String) -> void:
	var new_label: CommandOutputLabel = COMMAND_OUTPUT_LABEL_SCENE.instantiate()
	command_output_container.add_child(new_label)
	new_label.text = text
	
	update_scroll()


# Create and append a new CommandOutputLabel for every element in lines to the container
func push_lines_to_output(lines: Array[String]) -> void:
	for line: String in lines:
		var new_label: CommandOutputLabel = COMMAND_OUTPUT_LABEL_SCENE.instantiate()
		command_output_container.add_child(new_label)
		new_label.text = line
	
	update_scroll()


# Make the container scroll all the way down
# to keep the command input visible
func update_scroll() -> void:
	# Wait a process_frame to update the container correctly
	# if not, the scroll is going to jump to a position before
	# the new label added has changed the container size
	for x in range(3):
		#ALERT "hacky" way, awaiting just one frame can
		# make the problem cited above hapens anyway 
		await get_tree().process_frame
	scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value)


# Just queue_free all the labels
func clear_output() -> void:
	for child: CommandOutputLabel in command_output_container.get_children():
		child.queue_free()


# Get the FakeWindow that's the terminal is inside
func find_parent_window() -> FakeWindow:
	const MAX_ITERATIONS: int = 1000
	var node: Node = null
	
	for x: int in range(MAX_ITERATIONS):
		if node == null:
			node = get_parent() 
		else:
			node = node.get_parent()
		
		if node is FakeWindow and node.is_ancestor_of(self):
			break
	
	return node


# Called when the user presses enter with the command line in focus
func _on_command_line_text_submitted(new_text: String) -> void:
	command_line.clear()
	push_line_to_output(virtual_path_manager.get_current_folder() + " > " + new_text)
	
	# Return early if user input is a empty string
	if new_text.replace(" ", "") == "":
		return

	input_history_manager.push_to_history(new_text)
	
	var parser_outputs: Array[ParserOutput] = input_parser.parse(new_text)
	for output: ParserOutput in parser_outputs:
		if command_manager.cmd_exists(output.command_call_name):
			var cmd: TerminalCommand = command_manager.load_command(output.command_call_name)
			cmd.execute(self, output.command_args)
		else:
			push_line_to_output("%s not found" % [output.command_call_name])


func _on_command_line_gui_input(event: InputEvent) -> void:
	# Increments index and get input at that time
	if event.is_action_pressed("ui_text_caret_up"):
		command_line.text = input_history_manager.get_next(InputHistoryManager.DIR.UP)
		command_line.set_deferred("caret_column", command_line.text.length())
	
	# Decrements index and get input at that time
	elif event.is_action_pressed("ui_text_caret_down"):
		command_line.text = input_history_manager.get_next(InputHistoryManager.DIR.DOWN)
		command_line.set_deferred("caret_column", command_line.text.length())
