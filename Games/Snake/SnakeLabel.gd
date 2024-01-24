extends RichTextLabel

func _on_board_score_updated(new_score: int) -> void:
	self.text = "Score: " + str(new_score)
