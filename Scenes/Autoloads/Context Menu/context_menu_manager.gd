extends Panel

const right_click_handler: PackedScene = preload("res://Scenes/Autoloads/Context Menu/right_click_handler.tscn")
const context_menu_option: PackedScene = preload("res://Scenes/Autoloads/Context Menu/context_menu_option.tscn")

var target: Control

var is_mouse_over: bool

func _ready():
	visible = false
	get_tree().node_added.connect(_add_right_click_handler)

## Adds right click handler to every node in the group
func _add_right_click_handler(node: Node):
	if node.is_in_group("right_click_enabled"):
		node.add_child(right_click_handler.instantiate())

## This gets called from right_click_handler
func handle_right_click(node: Control):
	for option in $VBoxContainer.get_children():
		option.queue_free()
	
	if node is FakeFolder:
		target = node
		var rename_option: Control = context_menu_option.instantiate()
		if node.file_type == FakeFolder.file_type_enum.FOLDER:
			rename_option.get_node("%Option Text").text = "Rename Folder"
		else:
			rename_option.get_node("%Option Text").text = "Rename File"
		rename_option.option_clicked.connect(_handle_folder_rename)
		$VBoxContainer.add_child(rename_option)
	elif node is FileManagerWindow:
		target = node
		print("Hit a window")
	
	show_context_menu()

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == 1 and !is_mouse_over and visible:
			hide_context_menu()

func show_context_menu():
	visible = true
	global_position = get_global_mouse_position() + Vector2(10, 15)
	clamp_inside_viewport()
	modulate.a = 0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.3)

func hide_context_menu():
	var tween: Tween = create_tween()
	await tween.tween_property(self, "modulate:a", 0, 0.15).finished
	if modulate.a == 0:
		visible = false

func _on_mouse_entered():
	is_mouse_over = true

func _on_mouse_exited():
	is_mouse_over = false

func clamp_inside_viewport():
	var game_window_size: Vector2 = get_viewport_rect().size
	if (size.y > game_window_size.y - 40):
		size.y = game_window_size.y - 40
	if (size.x > game_window_size.x):
		size.x = game_window_size.x
	
	global_position.y = clamp(global_position.y, 0, game_window_size.y - size.y - 40)
	global_position.x = clamp(global_position.x, 0, game_window_size.x - size.x)

func _handle_folder_rename():
	target.get_node("%Folder Title Edit").show_rename()
