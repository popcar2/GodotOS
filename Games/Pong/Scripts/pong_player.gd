extends CharacterBody2D

const SPEED = 250.0

@export var up_axis: String = "ui_up"
@export var down_axis: String = "ui_down"

func _physics_process(delta):
	var direction = Input.get_axis(up_axis, down_axis)
	if direction:
		velocity.y = direction * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	move_and_collide(velocity * delta)
	
	position.y = clamp(position.y, -264, 264)
