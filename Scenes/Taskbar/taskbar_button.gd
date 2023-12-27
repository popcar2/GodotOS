extends Control

@onready var texture_margin: MarginContainer = $TextureMargin
@onready var texture_rect: TextureRect = $"TextureMargin/TextureRect"
@onready var selected_background: TextureRect = $SelectedBackground

var target_window: FakeWindow

var active_color: Color = Color("6de700")
var disabled_color: Color = Color("908a8c")

func _ready():
	target_window.minimized.connect(_on_window_minimized)
	target_window.deleted.connect(_on_window_deleted)
	target_window.selected.connect(_on_window_selected)
	texture_rect.self_modulate = active_color

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		if target_window.is_minimized:
			target_window.show_window()
		else:
			target_window.hide_window()

func _on_mouse_entered():
	texture_margin.add_theme_constant_override("margin_bottom", 7)
	texture_margin.add_theme_constant_override("margin_left", 7)
	texture_margin.add_theme_constant_override("margin_right", 7)
	texture_margin.add_theme_constant_override("margin_top", 7)

func _on_mouse_exited():
	texture_margin.add_theme_constant_override("margin_bottom", 5)
	texture_margin.add_theme_constant_override("margin_left", 5)
	texture_margin.add_theme_constant_override("margin_right", 5)
	texture_margin.add_theme_constant_override("margin_top", 5)

func _on_window_minimized(is_minimized: bool):
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if is_minimized:
		tween.tween_property(texture_rect, "self_modulate", disabled_color, 0.25)
	else:
		tween.tween_property(texture_rect, "self_modulate", active_color, 0.25)

func _on_window_deleted():
	queue_free()

func _on_window_selected(selected: bool):
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if selected:
		tween.tween_property(selected_background, "self_modulate:a", 1, 0.25)
	else:
		tween.tween_property(selected_background, "self_modulate:a", 0, 0.25)
