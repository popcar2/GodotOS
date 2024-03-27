extends Node
class_name GamePauseManager

## A generic pause manager for games in GodotOS.
## When you press ui_cancel, it pauses or unpauses.

## NOTE: This node disabled by default but gets enabled by start menu option
## if the generic pause menu bool is enabled there.

@export var pause_packed_scene: PackedScene

@onready var window: FakeWindow = $".."

var is_paused: bool
var current_pause_screen: CanvasLayer

func _input(event: InputEvent) -> void:
	if !window.is_selected:
		return
	
	if event.is_action_pressed("pause_game"):
		toggle_pause()

## Pauses and adds the pause screen as a child to the game scene.
## The reason for this is so the pause screen scales with the viewport.
func toggle_pause() -> void:
	if %"Game Window".get_child_count() == 0:
		NotificationManager.spawn_notification("Error: No game scene to pause???")
		return
	
	var game_scene: Node = %"Game Window".get_child(0)
	
	if is_paused:
		game_scene.process_mode = Node.PROCESS_MODE_INHERIT
		if current_pause_screen != null:
			current_pause_screen.queue_free()
	else:
		game_scene.process_mode = Node.PROCESS_MODE_DISABLED
		var pause_screen: CanvasLayer = pause_packed_scene.instantiate()
		game_scene.add_child(pause_screen)
		current_pause_screen = pause_screen
	
	is_paused = !is_paused
