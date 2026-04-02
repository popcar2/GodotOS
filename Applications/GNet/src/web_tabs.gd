extends Control
## Manages multiple browser tabs, each running their own WebScene instance.
## Tabs are created dynamically and share the same TabContent area.


const WEB_SCENE: PackedScene = preload("res://Applications/GNet/src/web_scene.tscn")
const MAX_TABS: int = 10
const TAB_MAX_WIDTH: int = 180

@onready var tabs: HBoxContainer = $VBox/TabBar/TabScroll/Tabs
@onready var new_tab_btn: Button = $VBox/TabBar/NewTabBtn
@onready var tab_content: Control = $VBox/TabContent

# Each entry: { "button": Button, "scene": Control }
var _tabs: Array[Dictionary] = []
var _active_index: int = -1


func _ready() -> void:
	$VBox/TabBar.custom_minimum_size.y = 32
	$VBox/TabBar/TabScroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$VBox/TabBar.move_child($VBox/TabBar/TabScroll, 0)
	$VBox/TabBar.move_child(new_tab_btn, 1)
	new_tab_btn.pressed.connect(_on_new_tab)
	open_tab()


# ── Public ────────────────────────────────────────────────────────────────────


func open_tab(url: String = "") -> void:
	if _tabs.size() >= MAX_TABS:
		return

	var scene: Control = WEB_SCENE.instantiate()
	scene.anchor_right = 1.0
	scene.anchor_bottom = 1.0
	scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene.visible = false
	tab_content.add_child(scene)

	# Connect to the browser's status label to update the tab title.
	scene.page_loaded.connect(func(title: String) -> void: _on_tab_title_changed(scene, title))

	# Replace the btn creation block in open_tab() with this:
	var tab_btn_container: HBoxContainer = HBoxContainer.new()
	tab_btn_container.custom_minimum_size.x = TAB_MAX_WIDTH

	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(120, 28)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_stylebox_override("normal", _make_tab_style(Color(0.2, 0.2, 0.2)))
	btn.add_theme_stylebox_override("pressed", _make_tab_style(Color(0.35, 0.35, 0.35)))
	btn.add_theme_stylebox_override("hover", _make_tab_style(Color(0.28, 0.28, 0.28)))
	btn.text = "New Tab"
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.clip_text = true
	btn.toggle_mode = true
	btn.pressed.connect(_on_tab_pressed.bind(_tabs.size()))

	var close_btn: Button = Button.new()
	close_btn.custom_minimum_size = Vector2(24, 28)
	close_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	close_btn.add_theme_stylebox_override("normal", _make_tab_style(Color(0.2, 0.2, 0.2)))
	close_btn.add_theme_stylebox_override("pressed", _make_tab_style(Color(0.5, 0.2, 0.2)))
	close_btn.add_theme_stylebox_override("hover", _make_tab_style(Color(0.4, 0.25, 0.25)))
	close_btn.text = "×"
	close_btn.custom_minimum_size.x = 24
	close_btn.pressed.connect(func() -> void: close_tab(_get_tab_index(tab_btn_container)))

	tab_btn_container.add_child(btn)
	tab_btn_container.add_child(close_btn)
	tabs.add_child(tab_btn_container)

	_tabs.append({"button": btn, "container": tab_btn_container, "scene": scene})
	_switch_to(_tabs.size() - 1)

	if url:
		scene.navigate(url)


func close_tab(index: int) -> void:
	if _tabs.size() <= 1:
		return

	var entry: Dictionary = _tabs[index]
	entry["scene"].queue_free()
	entry["container"].queue_free()  # frees both the label btn and close btn
	_tabs.remove_at(index)

	for i in _tabs.size():
		var btn: Button = _tabs[i]["button"]
		for connection: Dictionary in btn.pressed.get_connections():
			btn.pressed.disconnect(connection["callable"])
		btn.pressed.connect(_on_tab_pressed.bind(i))

	_switch_to(clampi(_active_index, 0, _tabs.size() - 1))


# ── Private ───────────────────────────────────────────────────────────────────


func _switch_to(index: int) -> void:
	if index < 0 or index >= _tabs.size():
		return

	# Hide the old tab.
	if _active_index >= 0 and _active_index < _tabs.size():
		_tabs[_active_index]["scene"].visible = false
		_tabs[_active_index]["button"].button_pressed = false

	_active_index = index
	_tabs[index]["scene"].visible = true
	_tabs[index]["button"].button_pressed = true


func _on_tab_pressed(index: int) -> void:
	_switch_to(index)


func _on_new_tab() -> void:
	open_tab()


func _on_tab_title_changed(scene: Control, title: String) -> void:
	for i in _tabs.size():
		if _tabs[i]["scene"] == scene:
			_tabs[i]["button"].text = title
			return
			
func _get_tab_index(container: Control) -> int:
	for i in _tabs.size():
		if _tabs[i]["container"] == container:
			return i
	return -1

func _make_tab_style(color: Color) -> StyleBoxFlat:
	var style: = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	return style
