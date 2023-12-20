extends Button

var boot_splash_scene: PackedScene = preload("res://Scenes/Main/Boot Splash/boot_splash.tscn")

func _on_pressed():
	var boot_splash: BootSplash = boot_splash_scene.instantiate()
	boot_splash.quit_animation = true
	get_tree().root.add_child(boot_splash)
