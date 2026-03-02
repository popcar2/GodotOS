extends CanvasLayer

signal start_game

@onready var label_title: Label = $Panel/VBoxContainer/Label
@onready var label_score: RichTextLabel = $Panel/VBoxContainer/Label2
@onready var button: Button = $Panel/VBoxContainer/Button

func _ready() -> void:
	label_title.text = "Flappy Pixel"
	label_score.text = ""
	button.text = "Start Game"

func _on_button_pressed() -> void:
	emit_signal("start_game")
	label_title.text = "Game Over"
	button.text = "Try Again"
