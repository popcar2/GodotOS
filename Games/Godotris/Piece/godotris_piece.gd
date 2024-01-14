extends Node2D

class_name GodotrisPiece

@export var spawn_offset: Vector2i
@export var container_offset: Vector2i

var child_count: int

func _ready() -> void:
	child_count = get_child_count()
	for block: GodotrisBlock in get_children():
		block.connect("cleared", on_block_cleared)

func on_block_cleared() -> void:
	child_count -= 1
	if child_count == 0:
		queue_free()
