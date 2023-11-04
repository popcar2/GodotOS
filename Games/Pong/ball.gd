extends CharacterBody2D

var collision_data: KinematicCollision2D

func _ready():
	velocity = Vector2(300,0)

func _physics_process(delta):
	collision_data = move_and_collide(velocity * delta)
	if collision_data:
		velocity.y += randf_range(-500, 500)
		velocity = velocity.bounce(collision_data.get_normal())
		velocity.y = clamp(velocity.y, -1000, 1000)
