extends CharacterBody2D

const SPEED = 250.0

@export var up_axis: String = "ui_up"
@export var down_axis: String = "ui_down"

var input_direction: float

func _input(event: InputEvent):
	input_direction =  event.get_action_strength(down_axis) - event.get_action_strength(up_axis)

func _physics_process(delta):
	if input_direction:
		velocity.y = input_direction * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	move_and_collide(velocity * delta)
	
	position.y = clamp(position.y, -264, 264)
