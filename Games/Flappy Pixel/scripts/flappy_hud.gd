extends CanvasLayer

@onready var label : Label = $Panel/Label

func set_label_text(points: int) -> void:
	label.text = "Points: %s" % points
