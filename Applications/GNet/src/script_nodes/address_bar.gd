extends LineEdit
## Address bar input field.
## Clears itself when focused so the user can type a new URL immediately
## without having to select and delete the old one first.


func _on_focus_entered() -> void:
	text = ""
