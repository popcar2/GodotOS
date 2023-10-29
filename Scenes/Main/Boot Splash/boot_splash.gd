extends CanvasLayer

var multiplier: float = 1.0
var start_screen_size: Vector2 = Vector2(1152, 648)

func _ready():
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.set_parallel(true)
	tween.tween_property($Logo, "scale", Vector2(5, 5), 2)
	tween.tween_property($CanvasGroup/Logo, "scale", Vector2(5, 5), 2)
	tween.tween_property($CanvasGroup/Background, "scale", $CanvasGroup/Background.scale * 2, 2)
	
	tween.tween_property($Logo, "self_modulate:a", 0, 1.5)
	
	await get_tree().create_timer(3).timeout
	queue_free()

func _physics_process(_delta):
	#WARNING be sure to change this if default resolution changes
	scale = DisplayServer.window_get_size() as Vector2 / start_screen_size
	#TODO keep aspect ratio?
