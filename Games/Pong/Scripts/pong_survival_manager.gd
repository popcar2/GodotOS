extends Node2D

var game_over: bool

var time_elapsed: float

func load_scene(path: String) -> void:
	var next_scene: Node = load(path).instantiate()
	add_sibling(next_scene)
	queue_free()

func _physics_process(delta: float) -> void:
	if game_over:
		return
	
	time_elapsed += delta
	$"Timer Text".text = "%02d:%02d" % [time_elapsed / 60, time_elapsed as int % 60]

func _on_player_fail_area_body_entered(_body: Node2D) -> void:
	game_over = true
	await get_tree().create_timer(0.5).timeout
	$"Game Over Screen".visible = true
	$"Timer Text".visible = false
	$"Game Over Screen/Game Over Title".text = "[center]You survived for %02d:%02d" % [time_elapsed / 60, time_elapsed as int % 60]

func _on_restart_btn_pressed() -> void:
	load_scene("res://Games/Pong/Scenes/pong_survival.tscn")

func _on_main_menu_btn_pressed() -> void:
	load_scene("res://Games/Pong/Scenes/pong_main_menu.tscn")
