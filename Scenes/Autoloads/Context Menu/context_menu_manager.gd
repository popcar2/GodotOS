extends Panel

const right_click_handler: PackedScene = preload("res://Scenes/Autoloads/Context Menu/right_click_handler.tscn")
const context_menu_option: PackedScene = preload("res://Scenes/Autoloads/Context Menu/context_menu_option.tscn")

var target: Control

var is_mouse_over: bool
var is_shown_recently: bool

func _ready():
	visible = false
	await get_tree().physics_frame # Give nodes a chance to add other children first
	for node in get_tree().get_nodes_in_group("right_click_enabled"):
		node.add_child(right_click_handler.instantiate())
	get_tree().node_added.connect(_add_right_click_handler)

## Adds right click handler to every node in the group
func _add_right_click_handler(node: Node):
	if node.is_in_group("right_click_enabled"):
		await node.ready # Give nodes a chance to add other children first
		node.add_child(right_click_handler.instantiate())

## This gets called from right_click_handler
func handle_right_click(node: Control):
	if is_shown_recently:
		return
	
	for option in $VBoxContainer.get_children():
		option.queue_free()
	
	if node is FakeFolder:
		target = node
		add_folder_options()
		play_cooldown()
	elif node is FileManagerWindow or DesktopFileManager:
		target = node
		add_file_manager_options()
		play_cooldown()
	
	show_context_menu()

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == 1 and visible:
			hide_context_menu()

func show_context_menu():
	visible = true
	global_position = get_global_mouse_position() + Vector2(10, 15)
	clamp_inside_viewport()
	modulate.a = 0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.15)

func hide_context_menu():
	var tween: Tween = create_tween()
	await tween.tween_property(self, "modulate:a", 0, 0.10).finished
	if modulate.a == 0:
		visible = false

# ----------

func add_folder_options():
	var type_name: String
	if target.file_type == FakeFolder.file_type_enum.FOLDER:
		type_name = "Folder"
	else:
		type_name = "File"
	
	var rename_option: Control = context_menu_option.instantiate()
	rename_option.get_node("%Option Text").text = "Rename %s" % type_name
	rename_option.option_clicked.connect(_handle_folder_rename)
	
	var delete_option: Control = context_menu_option.instantiate()
	delete_option.get_node("%Option Text").text = "Move to trash"
	delete_option.option_clicked.connect(_handle_folder_delete)
	
	$VBoxContainer.add_child(rename_option)
	$VBoxContainer.add_child(delete_option)

func add_file_manager_options():
	var new_folder_option: Control = context_menu_option.instantiate()
	new_folder_option.get_node("%Option Text").text = "New Folder"
	new_folder_option.option_clicked.connect(_handle_new_folder)
	
	var new_text_file_option: Control = context_menu_option.instantiate()
	new_text_file_option.get_node("%Option Text").text = "New Text File"
	new_text_file_option.option_clicked.connect(_handle_new_text_file)
	
	$VBoxContainer.add_child(new_folder_option)
	$VBoxContainer.add_child(new_text_file_option)

# ----------

func _handle_folder_rename():
	target.get_node("%Folder Title Edit").show_rename()

func _handle_folder_delete():
	target.delete_file()

func _handle_new_folder():
	target.new_folder()

func _handle_new_text_file():
	target.new_file(".txt", FakeFolder.file_type_enum.TEXT_FILE)

# ----------

func _on_mouse_entered():
	is_mouse_over = true

func _on_mouse_exited():
	is_mouse_over = false

func play_cooldown():
	is_shown_recently = true
	await get_tree().create_timer(0.1).timeout
	is_shown_recently = false

func clamp_inside_viewport():
	var game_window_size: Vector2 = get_viewport_rect().size
	if (size.y > game_window_size.y - 40):
		size.y = game_window_size.y - 40
	if (size.x > game_window_size.x):
		size.x = game_window_size.x
	
	global_position.y = clamp(global_position.y, 0, game_window_size.y - size.y - 40)
	global_position.x = clamp(global_position.x, 0, game_window_size.x - size.x)
