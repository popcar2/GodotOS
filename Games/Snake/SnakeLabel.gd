extends RichTextLabel


func _on_board_score_updated(old_score: Variant, new_score: Variant) -> void:
	self.text = "Score: " + str(new_score)
