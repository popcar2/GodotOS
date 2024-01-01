extends CharacterBody2D

const SPEED = 5.8

var ball: CharacterBody2D

func _ready() -> void:
	ball = $"../Ball"

func _physics_process(delta: float) -> void:
	global_position.y = move_toward(global_position.y, ball.global_position.y, SPEED)
	
	move_and_collide(velocity * delta)
	
	position.y = clamp(position.y, -264, 264)
