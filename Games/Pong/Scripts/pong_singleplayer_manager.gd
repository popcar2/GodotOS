extends Node2D

# These are for changing in multiplayer
@export var player_won_text: String = "You won!"
@export var enemy_won_text: String = "You lost..."
@export var restart_scene_string: String = "res://Games/Pong/Scenes/pong_singleplayer.tscn"

var player_score: int :
	set(score):
		player_score = score
		$"Player Score Text".text = str(score)
		if score >= 3:
			$"Game Over Screen".visible = true
			$"Game Over Screen/Game Over Title".text = "[center]%s" % player_won_text
var enemy_score: int :
	set(score):
		enemy_score = score
		$"Enemy Score Text".text = str(score)
		if score >= 3:
			$"Game Over Screen".visible = true
			$"Game Over Screen/Game Over Title".text = "[center]%s" % enemy_won_text

func load_scene(path: String):
	var next_scene: Node = load(path).instantiate()
	add_sibling(next_scene)
	queue_free()

func _on_restart_btn_pressed():
	load_scene(restart_scene_string)

func _on_main_menu_btn_pressed():
	load_scene("res://Games/Pong/Scenes/pong_main_menu.tscn")
