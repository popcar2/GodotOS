extends CharacterBody2D

const SPEED = 250.0

@export var up_axis: String = "ui_up"
@export var down_axis: String = "ui_down"

var up_input: bool
var down_input: bool

func _input(event: InputEvent) -> void:
	# For some reason get_action_strength() wouldn't work in multiplayer,
	# only one player could move at the same time
	if event.is_action_pressed(up_axis):
		up_input = true
	if event.is_action_released(up_axis):
		up_input = false
	if event.is_action_pressed(down_axis):
		down_input = event.is_action_pressed(down_axis)
	if event.is_action_released(down_axis):
		down_input = false
	

func _physics_process(delta: float) -> void:
	if up_input:
		velocity.y = -SPEED
	elif down_input:
		velocity.y = SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	move_and_collide(velocity * delta)
	
	position.y = clamp(position.y, -264, 264)
