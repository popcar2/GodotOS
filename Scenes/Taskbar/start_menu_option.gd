extends Panel

@export var game_scene: String
@export var title_text: String
@export var description_text: String

var is_mouse_over: bool

func _ready():
	$"Background Panel".visible = false
	%"Menu Title".text = "[center]%s" % title_text
	%"Menu Description".text = "[center]%s" % description_text

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		spawn_window()

func _on_mouse_entered():
	is_mouse_over = true
	$"Background Panel".visible = true
	$"Background Panel".modulate.a = 0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($"Background Panel", "modulate:a", 1, 0.25)

func _on_mouse_exited():
	is_mouse_over = false
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.tween_property($"Background Panel", "modulate:a", 0, 0.25).finished
	if !is_mouse_over:
		$"Background Panel".visible = false

# WARNING WARNING WARNING
# TODO find a better way than copying this from desktop_folder.gd
func spawn_window():
	var window: FakeWindow
	window = load("res://Scenes/Window/Game Window/game_window.tscn").instantiate()
	window.get_node("%Game Window").add_child(load(game_scene).instantiate())
	
	window.title_text = %"Menu Title".text
	get_tree().current_scene.add_child(window)
	
	var taskbar_button: MarginContainer = load("res://Scenes/Taskbar/taskbar_button.tscn").instantiate()
	taskbar_button.target_window = window
	get_tree().get_first_node_in_group("taskbar_buttons").add_child(taskbar_button)
