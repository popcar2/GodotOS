extends RichTextLabel

var best_score: int = 0


func _on_board_game_ended(final_score: int) -> void:
	if final_score <= best_score: return
	best_score = final_score

# Update the high score display on the next game, so the player
# can easily see on the "game over" screen that they beat the 
# current high score.
func _on_restart_button_pressed() -> void:
	self.text = "Best: " + str(best_score)
