extends Control

func load_scene(path: String) -> void:
	var next_scene: Node2D = load(path).instantiate()
	add_sibling(next_scene)
	queue_free()

func _on_singleplayer_btn_pressed() -> void:
	$MainContainer.visible = false
	$SingleplayerContainer.visible = true
	$TitleText.text = "[center]SINGLEPLAYER"

func _on_regular_single_btn_pressed() -> void:
	load_scene("res://Games/Pong/Scenes/pong_singleplayer.tscn")

func _on_survival_single_btn_pressed() -> void:
	load_scene("res://Games/Pong/Scenes/pong_survival.tscn")

func _on_multiplayer_btn_pressed() -> void:
	load_scene("res://Games/Pong/Scenes/pong_multiplayer.tscn")
