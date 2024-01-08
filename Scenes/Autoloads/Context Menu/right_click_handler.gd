extends Node

## This is added by context_menu_handler to any node that enters the tree
## That is of group "right_click_enabled"
## So the context menu manager can detect when something is right clicked.

# NOTE: This class might not be necessary when Godot 4.3 comes out, which includes
#       a function that can globally find control nodes. 

func _ready() -> void:
	get_parent().gui_input.connect(_parent_gui_input)

func _parent_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 2 and event.is_pressed():
		ContextMenu.handle_right_click(get_parent())
