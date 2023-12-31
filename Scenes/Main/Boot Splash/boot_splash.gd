extends CanvasLayer
class_name BootSplash

@export var quit_animation: bool

func _ready():
	visible = true
	scale /= get_window().content_scale_factor
	if quit_animation:
		play_quit_animation()
	else:
		play_animation()

func play_animation():
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.set_parallel(true)
	tween.tween_property($Logo, "scale", Vector2(10, 10), 2)
	tween.tween_property($CanvasGroup/Logo, "scale", Vector2(10, 10), 2)
	
	tween.tween_property($Logo, "self_modulate:a", 0, 1.5)
	
	await get_tree().create_timer(3).timeout
	queue_free()

func play_quit_animation():
	$Logo.scale = Vector2(10, 10)
	$Logo.self_modulate.a = 0
	$CanvasGroup/Logo.scale = Vector2(10, 10)
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.set_parallel(true)
	tween.tween_property($Logo, "scale", Vector2(1, 1), 2)
	tween.tween_property($CanvasGroup/Logo, "scale", Vector2(1, 1), 2)
	
	await get_tree().create_timer(1).timeout
	
	var tween2: Tween = create_tween()
	tween2.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property($Logo, "self_modulate:a", 1, 1.5)
	
	await get_tree().create_timer(2).timeout
	get_tree().quit()

func _physics_process(_delta):
	var window_size: Vector2 = DisplayServer.window_get_size() as Vector2
	$CanvasGroup/Background.scale = window_size
	$CanvasGroup/Background.global_position = window_size / 2
	$CanvasGroup/Logo.global_position = window_size / 2
	$Logo.global_position = window_size / 2
