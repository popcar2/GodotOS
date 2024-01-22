extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_board_score_updated(old_score: Variant, new_score: Variant) -> void:
	self.text = "Score: " + str(new_score)
