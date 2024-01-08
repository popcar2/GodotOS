extends Button

## The power button in the start menu. Does nothing if you're on the web version.

var boot_splash_scene: PackedScene = preload("res://Scenes/Main/Boot Splash/boot_splash.tscn")

func _on_pressed() -> void:
	if OS.has_feature("web"):
		NotificationManager.spawn_notification("You can't shut down the web version of GodotOS!")
		return
	var boot_splash: BootSplash = boot_splash_scene.instantiate()
	boot_splash.quit_animation = true
	get_tree().root.add_child(boot_splash)
