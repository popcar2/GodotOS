extends Sprite2D

class_name GodotrisBlock

signal cleared

func clear() -> void:
	cleared.emit()
	queue_free()
