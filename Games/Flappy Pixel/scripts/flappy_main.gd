extends Node2D

@export var pipe: PackedScene
@export var coin: PackedScene

@onready var deathScreen: CanvasLayer = $DeathScreen
@onready var bg: ParallaxBackground = $Background
@onready var bird: CharacterBody2D = $Bird
@onready var label_score: RichTextLabel = $DeathScreen/Panel/VBoxContainer/Label2
@onready var medal: RichTextLabel = $DeathScreen/Panel/VBoxContainer/Medal

var delay: float = 1.0
var spawnPipe: bool = false
var game_running: bool = true

enum MedalTitles {
	BRUH = 0,
	GETTING_BETTER = 10,
	NICE = 20,
	PRO = 40,
	MASTER = 60,
	LEGEND = 80,
	INSANE = 100
}

func criar_item()-> void:
	if not game_running:
		return

	var Inst : Node
	spawnPipe = !spawnPipe

	if spawnPipe:
		Inst = pipe.instantiate()
	else:
		Inst = coin.instantiate()

	Inst.position.x = 1200
	Inst.add_to_group("movable")
	add_child(Inst)
	
	$Timer.wait_time = delay
	$Timer.start()


func _ready() -> void:
	criar_item()


func _on_timer_timeout() -> void:
	criar_item()
	$Timer.start(delay)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_text_clear_carets_and_selection"):
		get_tree().quit()

	if game_running and bird.life <= 0:
		game_running = false
		deathScreen.show()

		for obj in get_tree().get_nodes_in_group("movable"):
			obj.canMove = false

		bg.can_move = false


func _on_death_screen_start_game() -> void:
	deathScreen.hide()

	for obj in get_tree().get_nodes_in_group("movable"):
		obj.queue_free()

	bird.reset_player()

	game_running = true
	bg.can_move = true


func _on_bird_died() -> void:
	var new_best: bool = bird.check_highscore()
	var score: int = bird.points
	
	label_score.bbcode_enabled = true
	medal.bbcode_enabled = true

	if new_best:
		label_score.bbcode_text = "[wave amp=30 freq=5][rainbow sat=0.8 val=1 freq=1]New Best!\nHighscore: %d[/rainbow][/wave]" % bird.highscore
	else:
		label_score.bbcode_text = "Highscore: %d" % bird.highscore
	
	if score >= MedalTitles.INSANE:
		medal.bbcode_text = "[rainbow sat=1 val=1 freq=2][wave amp=40 freq=5]INSANE![/wave][/rainbow]"
	elif score >= MedalTitles.LEGEND:
		medal.bbcode_text = "[rainbow sat=0.9 val=1 freq=1]Legendary[/rainbow]"
	elif score >= MedalTitles.MASTER:
		medal.bbcode_text = "[wave amp=20 freq=6]Master Player![/wave]"
	elif score >= MedalTitles.PRO:
		medal.bbcode_text = "[wave amp=15 freq=4]Pro Gamer XD[/wave]"
	elif score >= MedalTitles.NICE:
		medal.bbcode_text = "[color=yellow]Pretty Nice![/color]"
	elif score >= MedalTitles.GETTING_BETTER:
		medal.bbcode_text = "[color=green]We are getting better...[/color]"
	else:
		medal.bbcode_text = "[color=gray]Bruh[/color]"
