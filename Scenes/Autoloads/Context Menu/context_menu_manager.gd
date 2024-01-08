extends Panel

## An autoload to manage the context menu (right click menu)

const right_click_handler: PackedScene = preload("res://Scenes/Autoloads/Context Menu/right_click_handler.tscn")
const context_menu_option: PackedScene = preload("res://Scenes/Autoloads/Context Menu/context_menu_option.tscn")
const context_menu_seperator: PackedScene = preload("res://Scenes/Autoloads/Context Menu/context_menu_seperator.tscn")

## The Control node that got right clicked.
var target: Control

## Checks if the mouse is currently over the menu
var is_mouse_over: bool

## Used as a cooldown for not spawning the right click menu dozens of times per second
var is_shown_recently: bool

func _ready() -> void:
	visible = false
	await get_tree().physics_frame # Give nodes a chance to add other children first
	for node in get_tree().get_nodes_in_group("right_click_enabled"):
		node.add_child(right_click_handler.instantiate())
	get_tree().node_added.connect(_add_right_click_handler)

## Adds right click handler to every node in the group
func _add_right_click_handler(node: Node) -> void:
	if node.is_in_group("right_click_enabled"):
		await node.ready # Give nodes a chance to add other children first
		node.add_child(right_click_handler.instantiate())

## This gets called from right_click_handler
func handle_right_click(node: Control) -> void:
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == 1 and visible:
			hide_context_menu()

func show_context_menu() -> void:
	visible = true
	global_position = get_global_mouse_position() + Vector2(10, 15)
	clamp_inside_viewport()
	modulate.a = 0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.15)

func hide_context_menu() -> void:
	var tween: Tween = create_tween()
	await tween.tween_property(self, "modulate:a", 0, 0.10).finished
	if modulate.a == 0:
		visible = false

# ----------

## Adds options that would be visible when right clicking a folder
func add_folder_options() -> void:
	var type_name: String
	if target.file_type == FakeFolder.file_type_enum.FOLDER:
		type_name = "Folder"
	else:
		type_name = "File"
	
	var rename_option: Control = context_menu_option.instantiate()
	rename_option.get_node("%Option Text").text = "Rename %s" % type_name
	rename_option.option_clicked.connect(_handle_folder_rename)
	
	var copy_option: Control = context_menu_option.instantiate()
	copy_option.get_node("%Option Text").text = "Copy %s" % type_name
	copy_option.option_clicked.connect(_handle_copy_folder)
	
	var cut_option: Control = context_menu_option.instantiate()
	cut_option.get_node("%Option Text").text = "Cut %s" % type_name
	cut_option.option_clicked.connect(_handle_cut_folder)
	
	var delete_option: Control = context_menu_option.instantiate()
	delete_option.get_node("%Option Text").text = "Move to trash"
	delete_option.option_clicked.connect(_handle_folder_delete)
	
	$VBoxContainer.add_child(rename_option)
	
	if target.file_type == FakeFolder.file_type_enum.IMAGE:
		var set_wallpaper_option: Control = context_menu_option.instantiate()
		set_wallpaper_option.get_node("%Option Text").text = "Set as wallpaper"
		set_wallpaper_option.option_clicked.connect(_handle_set_wallpaper)
		$VBoxContainer.add_child(set_wallpaper_option)
	
	$VBoxContainer.add_child(context_menu_seperator.instantiate())
	$VBoxContainer.add_child(copy_option)
	$VBoxContainer.add_child(cut_option)
	$VBoxContainer.add_child(context_menu_seperator.instantiate())
	$VBoxContainer.add_child(delete_option)

## Adds options that would be visible when right clicking a file manager
func add_file_manager_options() -> void:
	var new_folder_option: Control = context_menu_option.instantiate()
	new_folder_option.get_node("%Option Text").text = "New Folder"
	new_folder_option.option_clicked.connect(_handle_new_folder)
	
	var new_text_file_option: Control = context_menu_option.instantiate()
	new_text_file_option.get_node("%Option Text").text = "New Text File"
	new_text_file_option.option_clicked.connect(_handle_new_text_file)
	
	if !CopyPasteManager.target_folder_name.is_empty():
		var paste_folder_option: Control = context_menu_option.instantiate()
		if CopyPasteManager.target_folder_type == FakeFolder.file_type_enum.FOLDER:
			paste_folder_option.get_node("%Option Text").text = "Paste Folder"
		else:
			paste_folder_option.get_node("%Option Text").text = "Paste File"
		paste_folder_option.option_clicked.connect(_handle_paste_folder)
		
		$VBoxContainer.add_child(paste_folder_option)
		$VBoxContainer.add_child(context_menu_seperator.instantiate())
	$VBoxContainer.add_child(new_folder_option)
	$VBoxContainer.add_child(new_text_file_option)

# ----------

func _handle_folder_rename() -> void:
	target.get_node("%Folder Title Edit").show_rename()

func _handle_set_wallpaper() -> void:
	# TODO make this a relative path?
	get_node("/root/Control/Wallpaper").apply_wallpaper_from_file(target)

func _handle_folder_delete() -> void:
	target.delete_file()

func _handle_new_folder() -> void:
	target.new_folder()

func _handle_new_text_file() -> void:
	target.new_file(".txt", FakeFolder.file_type_enum.TEXT_FILE)

func _handle_copy_folder() -> void:
	CopyPasteManager.copy_folder(target)

func _handle_cut_folder() -> void:
	CopyPasteManager.cut_folder(target)

func _handle_paste_folder() -> void:
	CopyPasteManager.paste_folder(target.file_path)
# ----------

func _on_mouse_entered() -> void:
	is_mouse_over = true

func _on_mouse_exited() -> void:
	is_mouse_over = false

func play_cooldown() -> void:
	is_shown_recently = true
	await get_tree().create_timer(0.1).timeout
	is_shown_recently = false

func clamp_inside_viewport() -> void:
	var game_window_size: Vector2 = get_viewport_rect().size
	if (size.y > game_window_size.y - 40):
		size.y = game_window_size.y - 40
	if (size.x > game_window_size.x):
		size.x = game_window_size.x
	
	global_position.y = clamp(global_position.y, 0, game_window_size.y - size.y - 40)
	global_position.x = clamp(global_position.x, 0, game_window_size.x - size.x)
