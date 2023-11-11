extends CharacterBody2D

var collision_data: KinematicCollision2D

@export var speed_gain_percent: float = 1.03
@export var rand_angle: float = 50

func _ready():
	velocity = Vector2(400,0)

func _physics_process(delta):
	collision_data = move_and_collide(velocity * delta)
	if collision_data:
		if collision_data.get_collider() is CharacterBody2D:
			if velocity.x < 700:
				velocity.x *= speed_gain_percent
			elif velocity.x < 900:
				velocity.x *= speed_gain_percent / 2
			else:
				velocity.x *= speed_gain_percent / 4
			velocity.y += (global_position.y - collision_data.get_collider().global_position.y) * 4
			velocity.y += randf_range(-rand_angle, rand_angle)
		velocity = velocity.bounce(collision_data.get_normal())
		velocity.y = clamp(velocity.y, -1000, 1000)

func reset_ball():
	if get_parent().player_score >= 3 or get_parent().enemy_score >= 3:
		return
	
	velocity = Vector2.ZERO
	global_position = Vector2.ZERO
	
	await get_tree().create_timer(1).timeout
	velocity = Vector2(300, 0)
