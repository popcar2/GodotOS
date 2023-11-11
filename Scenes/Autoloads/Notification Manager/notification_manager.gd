extends Control

const notification_scene: PackedScene = preload("res://Scenes/Autoloads/Notification Manager/notification.tscn")

func spawn_notification(text: String):
	var new_notification = notification_scene.instantiate()
	new_notification.get_node("Notification Text").text = "[center]%s" % text
	add_child(new_notification)
