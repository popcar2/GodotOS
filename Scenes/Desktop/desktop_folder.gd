extends Control

func _ready():
	$Highlight.self_modulate.a = 0

func _on_mouse_entered():
	show_highlight()

func _on_mouse_exited():
	hide_highlight()

# ------

func show_highlight():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Highlight, "self_modulate:a", 1, 0.25).from(0.1)

func hide_highlight():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Highlight, "self_modulate:a", 0, 0.25)
