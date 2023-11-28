extends CharacterBody2D

const ACCELERATION: float = 50.0
const SPEED: float = 400.0
const JUMP_VELOCITY: float = -600.0
const GRAVITY: float = 980.0

var bonus_velocity: Vector2

var x_direction: float
var left_walljump_active: bool
var right_walljump_active: bool

# TODO put input in _input() which for some reason is a pain in the ass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif left_walljump_active:
			walljump(true)
		elif right_walljump_active:
			walljump(false)
	
	x_direction = Input.get_axis("move_left", "move_right")
	if x_direction:
		velocity.x += x_direction * ACCELERATION
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION / 2)
	
	if velocity.x > 400:
		velocity.x = move_toward(velocity.x, 400, ACCELERATION)
	elif velocity.x < -400:
		velocity.x = move_toward(velocity.x, -400, ACCELERATION)
	
	velocity += bonus_velocity
	if bonus_velocity:
		bonus_velocity.x = move_toward(bonus_velocity.x, 0, ACCELERATION)
		bonus_velocity.y = move_toward(bonus_velocity.y, 0, ACCELERATION)
	print(velocity.x)
	
	move_and_slide()

func walljump(left: bool):
	if velocity.y > 0:
		velocity.y = JUMP_VELOCITY * 0.90
	else:
		velocity.y += JUMP_VELOCITY * 0.90
	if left:
		velocity.x = 400
		bonus_velocity.x += 150
	else:
		velocity.x = -400
		bonus_velocity.x -= 150

func _on_left_wall_jump_area_2d_body_entered(body):
	if body is StaticBody2D:
		left_walljump_active = true


func _on_left_wall_jump_area_2d_body_exited(body):
	if body is StaticBody2D:
		left_walljump_active = false

func _on_right_wall_jump_area_2d_body_entered(body):
	if body is StaticBody2D:
		right_walljump_active = true


func _on_right_wall_jump_area_2d_body_exited(body):
	if body is StaticBody2D:
		right_walljump_active = false
