extends Control

signal new_game_should_start


func _on_board_game_ended(final_score: int) -> void:
	self.show()

func _on_button_pressed() -> void:
	self.hide()
	new_game_should_start.emit()
