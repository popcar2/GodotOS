extends Node2D

@export var next_scene_str: String

var is_loading: bool

func reload_scene() -> void:
	if is_loading:
		return
	
	is_loading = true
	var current_scene: Node = load(scene_file_path).instantiate()
	add_sibling(current_scene)
	queue_free()

func load_next_scene() -> void:
	if is_loading:
		return
	
	is_loading = true
	var next_scene: Node = load(next_scene_str).instantiate()
	add_sibling(next_scene)
	queue_free()
