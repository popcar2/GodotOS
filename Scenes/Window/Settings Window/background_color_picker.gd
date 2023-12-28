extends ColorPickerButton

func _ready():
	get_picker().presets_visible = false
	get_picker().deferred_mode = true
	get_picker().sliders_visible = true
	color = RenderingServer.get_default_clear_color()

func _on_color_changed(new_color):
	RenderingServer.set_default_clear_color(new_color)
