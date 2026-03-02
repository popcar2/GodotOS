extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -320.0
var life: int = 0
var points: int = 0
var highscore: int = 0

@export var shadow: PackedScene
@onready var hud: CanvasLayer = $Hud
@onready var sfx: Node = $sfx
@onready var song: AudioStreamPlayer2D = $song

@onready var initialPosition : Vector2

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var alive: bool = true

signal died

func _ready() -> void:
	initialPosition = position

func add_point() -> void:
	points += 1
	hud.set_label_text(points)
	if sfx:
		sfx.play_coin() 

func check_highscore() -> bool:
	if points > highscore:
		highscore = points
		return true
	return false

func _physics_process(delta: float) -> void: 
	if life > 0:
		if (is_on_ceiling() or is_on_wall() or is_on_floor()) and alive:
			emit_signal("died")
			life = 0
			alive = false
			if sfx:
				sfx.play_death()
			if song:
				song.stop_song()

		if not is_on_floor():
			velocity.y += gravity * delta

		# Pulo
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			var shadowInst : Node = shadow.instantiate()
			shadowInst.position = global_position  
			get_parent().add_child(shadowInst)  
			if song and not song.is_playing_song:
				song.start_song()

		if velocity.y < 90:
			if self.rotation > -.3:
				self.rotation -= 10 * delta
		else:
			velocity.y = 300

		if velocity.y > 90:
			if self.rotation < 1:
				self.rotation += 4 * delta

		move_and_slide()
	if not alive and life == 1:
		alive = true

func reset_player() -> void:
	hud.set_label_text(0)
	position = initialPosition
	velocity = Vector2.ZERO
	rotation = 0
	points = 0
	life = 1
	if song:
		song.stop_song()
