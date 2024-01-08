extends ColorPickerButton

## The background color picker used in the settings menu.

@onready var background_color: ColorRect = $"/root/Control/BackgroundColor"

func _ready() -> void:
	if !background_color:
		printerr("background_color_picker.gd: Couldn't find background color (are you debugging the settings menu?)")
		return
	
	get_picker().presets_visible = false
	get_picker().deferred_mode = true
	get_picker().sliders_visible = true
	color = background_color.color

func _on_color_changed(new_color: Color) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(background_color, "color", new_color, 0.5)
	DefaultValues.save_state()
