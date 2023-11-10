extends CharacterBody2D

const SPEED = 250.0

@export var up_axis: String = "ui_up"
@export var down_axis: String = "ui_down"

var input_direction: float

func _input(event: InputEvent):
	# For some reason get_action_strength() wouldn't work in multiplayer,
	# only one player could move at the same time
	if event.is_action_pressed(down_axis):
		input_direction = 1
	if event.is_action_released(down_axis):
		input_direction = 0
	if event.is_action_pressed(up_axis):
		input_direction = -1
	if event.is_action_released(up_axis):
		input_direction = 0
	

func _physics_process(delta):
	if input_direction:
		velocity.y = input_direction * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	move_and_collide(velocity * delta)
	
	position.y = clamp(position.y, -264, 264)
