extends CharacterBody2D

var collision_data: KinematicCollision2D

func _ready():
	velocity = Vector2(350,0)

func _physics_process(delta):
	collision_data = move_and_collide(velocity * delta)
	if collision_data:
		if collision_data.get_collider() is CharacterBody2D:
			velocity.x *= 1.03
			velocity.y += (global_position.y - collision_data.get_collider().global_position.y) * 4
			velocity.y += randf_range(-50, 50)
		velocity = velocity.bounce(collision_data.get_normal())
		velocity.y = clamp(velocity.y, -1000, 1000)

func reset_ball():
	velocity = Vector2.ZERO
	global_position = Vector2.ZERO
	
	await get_tree().create_timer(1).timeout
	velocity = Vector2(300, 0)
