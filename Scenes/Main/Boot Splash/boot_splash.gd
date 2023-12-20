extends CanvasLayer

var start_screen_size: Vector2 = Vector2(1152, 648)

func _ready():
	visible = true
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.set_parallel(true)
	tween.tween_property($Logo, "scale", Vector2(10, 10), 2)
	tween.tween_property($CanvasGroup/Logo, "scale", Vector2(10, 10), 2)
	
	tween.tween_property($Logo, "self_modulate:a", 0, 1.5)
	
	await get_tree().create_timer(3).timeout
	queue_free()

func _physics_process(_delta):
	var window_size: Vector2 = DisplayServer.window_get_size() as Vector2
	$CanvasGroup/Background.scale = window_size
	$CanvasGroup/Background.global_position = window_size / 2
	$CanvasGroup/Logo.global_position = window_size / 2
	$Logo.global_position = window_size / 2
