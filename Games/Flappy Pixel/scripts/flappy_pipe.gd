extends Node2D

@export var canMove : bool

func _ready() -> void:
	canMove = true
	randomize()
	var y_range : Vector2 = Vector2(100, 400)
	var random_y : float =  randi() % int(y_range[1]-y_range[0]) + 1 + y_range[0]
	self.position.y = random_y


func _process(_delta: float) -> void:
	if canMove:
		self.position.x -= 2

	if position.x < -100:
			queue_free()
