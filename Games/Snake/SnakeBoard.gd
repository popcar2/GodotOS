extends Sprite2D

class_name SnakeBoard

# This script runs basically the whole "snake" game.
# It lives in the rectangle where we display the game.

signal score_updated(old_score:int, new_score:int)
signal game_ended(final_score:int)

var board_image: Image
var sizeX := 68
var sizeY := 32
@export var bg_color: Color = Color.BLACK
@export var snake_color: Color = Color.WHITE
@export var apple_color: Color = Color.GREEN
# position of the snake's head
var head: Vector2i = Vector2i(1,1)
# position of the elments of the snake's body
# (front of list = front of snake)
var body: Array[Vector2i] = []
# direction it's going
var dir: Vector2i = Vector2i(1,0)
var initial_length := 5
var length_increase := 10
var time: float = 0.0
var time_per_tick := 1.0/20.0
var inputs: Array[Vector2i] = []
var score:= 0
var apple: Vector2i = Vector2i(10,10)
var playing:= true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_image = Image.new()
	board_image = Image.create(sizeX, sizeY, false, Image.FORMAT_RGB8)
	self.texture = ImageTexture.create_from_image(board_image)
	init_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !playing: return
	time += delta;
	while time>time_per_tick:
		time -= time_per_tick;
		tick()
		
# Called when a key is pressed (or released, technically)
func _input(event: InputEvent) -> void:
	if !playing: return
	if !(event is InputEventKey and event.is_pressed()):
		return
	match event.keycode:
		KEY_DOWN:
			inputs.push_back(Vector2i(0,1))
		KEY_LEFT:
			inputs.push_back(Vector2i(-1,0))
		KEY_RIGHT:
			inputs.push_back(Vector2i(1,0))
		KEY_UP:
			inputs.push_back(Vector2i(0,-1))

func start_game() -> void:
	init_game()
	playing = true
	
func init_game() -> void:
	inc_score(-score)
	board_image.fill(bg_color)
	self.texture.update(board_image)
	head = Vector2i(1,1)
	body = []
	dir = Vector2i(1,0)
	for i in range(initial_length):
		body.push_back(head)
	place_apple()
	
func place_apple() -> void:
	var attempts:= 100
	while (attempts > 0):
		attempts -= 1
		var pos := Vector2i(randi_range(0, sizeX-1), randi_range(0, sizeY-1))
		var pix: Color = board_image.get_pixel(pos.x, pos.y)
		if pix!=bg_color: continue
		apple = pos
		board_image.set_pixel(apple.x, apple.y, apple_color)
		return
	print("Unable to place apple (?)")
	
func inc_score(delta: int) -> void:
	score += delta
	score_updated.emit(score-delta, score)
	
func eat_apple() -> void:
	inc_score(10)
	place_apple()
	for i in range(length_increase):
		body.push_back(body[-1])
	
func game_over() -> void:
	playing = false
	game_ended.emit(score)
	
func in_bounds(pos: Vector2i) -> bool:
	return !(pos.x<0 || pos.y<0 || pos.x >= self.sizeX || pos.y >= self.sizeY)

# Run one frame of the game. Pops from inputs.
func tick() -> void:
	if inputs:
		var new_dir: Vector2i = inputs.pop_front()
		# ignore command to go backwards
		if new_dir != -dir:
			dir = new_dir
	head += dir
	if !in_bounds(head):
		# hit the edge, you die
		game_over()
		return
	var gone: Vector2i = body.pop_back()
	body.push_front(head)
	var pix: Color = board_image.get_pixel(head.x, head.y)
	board_image.set_pixel(apple.x, apple.y, apple_color)
	board_image.set_pixel(head.x, head.y, snake_color)
	board_image.set_pixel(gone.x, gone.y, bg_color)
	self.texture.update(board_image)
	if pix == snake_color:
		# self-collision, you die.
		game_over()
		return
	elif pix == apple_color:
		eat_apple()
	

func _on_play_button_pressed() -> void:
	start_game()
