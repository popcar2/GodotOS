extends Node2D

@export var next_scene: String

var is_loading: bool

func reload_scene():
	if is_loading:
		return
	
	is_loading = true
	var current_scene: Node = load(scene_file_path).instantiate()
	add_sibling(current_scene)
	queue_free()
