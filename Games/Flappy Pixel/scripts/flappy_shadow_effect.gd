extends Sprite2D

func _ready() -> void:
	self_modulate = Color(1, 1, 1, 1)
	ghosting()

func ghosting() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Color(1, 1, 1, 0), 0.75)
	await tween.finished
	queue_free()

func _process(_delta: float) -> void:
	position.x -= 1
