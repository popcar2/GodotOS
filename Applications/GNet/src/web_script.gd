extends Control
## Main browser controller. Handles navigation, page fetching,
## HTML parsing, image loading, and rendering into a RichTextLabel.
##
## Flow for a page load:
##   navigate() → _fetch() → HTTPRequest → _on_request_completed()
##     → HtmlParser.to_bbcode() → render text immediately
##     → ImageLoader.fetch_all() → _on_image_ready() per image
##     → _inject_content_with_textures() rebuilds content with real textures
##     → _on_all_images_done() → final status update

signal page_loaded(title: String)

const DEFAULT_HOME: String = ""
const MAX_REDIRECTS: int = 5
const DOWNLOAD_EXTENSIONS: Array[String] = [
	"pdf", "zip", "tar", "gz", "exe", "dmg", "pkg",
	"mp3", "mp4", "wav", "ogg", "avi", "mkv",
	"png", "jpg", "jpeg", "gif", "svg", "webp",
	"txt", "md", "csv", "json", "xml", "gd", "py",
	"doc", "docx", "xls", "xlsx", "ppt", "pptx",
]

@onready var address_bar: LineEdit = $VBox/TopBar/AddressBar
@onready var back_btn: Button = $VBox/TopBar/BackBtn
@onready var forward_btn: Button = $VBox/TopBar/ForwardBtn
@onready var refresh_btn: Button = $VBox/TopBar/RefreshBtn
@onready var go_btn: Button = $VBox/TopBar/GoBtn
@onready var status_label: Label = $VBox/StatusBar/StatusLabel
@onready var loading_bar: ProgressBar = $VBox/StatusBar/LoadingBar
@onready var content: RichTextLabel = $VBox/ScrollContainer/CenterContainer/MarginContainer/Content
@onready var image_loader: ImageLoader = $ImageLoader
@onready var http: HTTPRequest = $HTTPRequest
@onready var bg: ColorRect = $bg
@onready var context_menu: PopupMenu = _create_context_menu()

var history: BrowserHistory = BrowserHistory.new()
var _current_url: String = ""
var _redirect_count: int = 0
var _pending_bbcode: String = ""
# Textures keyed by resolved image URL — populated as images finish loading.
var _image_textures: Dictionary = {}

var _context_target_url: String = ""
var _context_target_src: String = ""
var _context_is_image: bool = false


func _ready() -> void:
	http.request_completed.connect(_on_request_completed)
	content.meta_clicked.connect(_on_link_clicked)
	image_loader.image_ready.connect(_on_image_ready)
	image_loader.all_done.connect(_on_all_images_done)
	back_btn.pressed.connect(_on_back)
	forward_btn.pressed.connect(_on_forward)
	refresh_btn.pressed.connect(_on_refresh)
	go_btn.pressed.connect(_on_go)
	address_bar.text_submitted.connect(_on_address_submitted)
	content.meta_hover_started.connect(_on_meta_hover_started)
	content.meta_hover_ended.connect(_on_meta_hover_ended)
	content.gui_input.connect(_on_content_gui_input)

	if DEFAULT_HOME != "":
		navigate(DEFAULT_HOME)


# ── Navigation ────────────────────────────────────────────────────────────────


# Public entry point for all navigation. Normalises the URL first
# (adds https://, or converts bare words to a search query).
func navigate(url: String) -> void:
	url = _normalize_url(url)
	_redirect_count = 0
	_fetch(url)


func _fetch(url: String) -> void:
	# Clear state from the previous page so stale textures don't bleed through.
	_image_textures.clear()
	_pending_bbcode = ""

	_current_url = url
	address_bar.text = url
	_set_loading(true)
	status_label.text = "Connecting to %s…" % url

	# Spoof a real browser User-Agent — some servers reject requests without one.
	var headers: Array[String] = [
		"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
		"Accept: text/html,application/xhtml+xml,*/*;q=0.8",
		"Accept-Language: en-US,en;q=0.9",
	]

	http.cancel_request()
	var err: int = http.request(url, headers)
	if err != OK:
		_show_error("Request failed (error %d)" % err)


# ── HTTPRequest callback ──────────────────────────────────────────────────────


func _on_request_completed(
		result: int, code: int,
		headers: PackedStringArray, body: PackedByteArray) -> void:
	_set_loading(false)

	if result != HTTPRequest.RESULT_SUCCESS:
		_show_error("Network error (result %d)" % result)
		return

	# Follow HTTP redirects up to MAX_REDIRECTS times.
	if code in [301, 302, 303, 307, 308]:
		var location: String = _get_header(headers, "location")
		if location and _redirect_count < MAX_REDIRECTS:
			_redirect_count += 1
			_fetch(_resolve_url(location, _current_url))
			return
		else:
			_show_error("Too many redirects.")
			return

	if code < 200 or code >= 300:
		_show_error("HTTP %d" % code)
		return

	var html: String = body.get_string_from_utf8()

	# to_bbcode() calls inject_image_placeholders() internally — don't pre-process.
	_pending_bbcode = HtmlParser.to_bbcode(html)

	# Apply the page's background color before rendering text.
	var bg_color: String = HtmlParser.extract_body_bg(html)
	bg.color = Color(bg_color) if bg_color else Color(0.25, 0.25, 0.25)

	# Render text immediately — [[IMG:]] placeholders show as raw text until
	# their textures are ready and _inject_content_with_textures() runs.
	content.bbcode_enabled = true
	content.text = _pending_bbcode

	# Always push to history here, regardless of whether there are images.
	history.push(_current_url)
	_update_nav_buttons()

	var images: Array[Dictionary] = HtmlParser.extract_images(html)
	images.append_array(HtmlParser.extract_inline_svgs(html))

	if images.is_empty():
		_finish_page(html)
		return

	status_label.text = "Loading images…"
	var srcs: Array[String] = []
	for img_data in images:
		srcs.append(_resolve_url(img_data["src"], _current_url))
	image_loader.fetch_all(srcs, _current_url)


func _finish_page(html: String) -> void:
	var title: String = _extract_title(html)
	status_label.text = "✓  %s" % (title if title else _current_url)
	page_loaded.emit(title if title else _current_url)


# ── Link clicks ───────────────────────────────────────────────────────────────


func _on_link_clicked(meta: Variant) -> void:
	var url: String = str(meta)
	if url.begins_with("__YTOPEN__"):
		OS.shell_open(url.substr(10))
		return
	
	# Check if the URL points to a downloadable file.
	var ext: String = url.get_file().get_extension().to_lower()
	if ext in DOWNLOAD_EXTENSIONS:
		_start_download(url)
		return
	
	navigate(_resolve_url(url, _current_url))


# ── Toolbar signal handlers ───────────────────────────────────────────────────


func _on_go() -> void:
	navigate(address_bar.text.strip_edges())


func _on_address_submitted(text: String) -> void:
	text = text.strip_edges()
	if _is_search_query(text):
		status_label.text = 'Searching for "%s"…' % text
	navigate(text)


func _on_back() -> void:
	if history.can_go_back():
		_fetch(history.go_back())
		_update_nav_buttons()


func _on_forward() -> void:
	if history.can_go_forward():
		_fetch(history.go_forward())
		_update_nav_buttons()


func _on_refresh() -> void:
	if _current_url:
		_fetch(_current_url)


# ── Image handling ────────────────────────────────────────────────────────────


func _on_image_ready(src: String, texture: ImageTexture) -> void:
	_image_textures[src] = texture
	_inject_content_with_textures()


func _on_all_images_done() -> void:
	_inject_content_with_textures()
	status_label.text = "✓  %s" % _current_url
	page_loaded.emit(_current_url)


# Rebuilds the RichTextLabel content, replacing every [[IMG:url]] placeholder
# with the decoded texture (if available) or a fallback label.
# Called once per image as they arrive so the page fills in progressively.
func _inject_content_with_textures() -> void:
	content.clear()
	content.bbcode_enabled = true

	var remaining: String = _pending_bbcode

	# Matches optional [url=...] wrapping around [[IMG:url]] placeholders
	# so we can make image links clickable.
	var img_regex: = RegEx.new()
	img_regex.compile("(\\[url=([^\\]]+)\\])?\\[\\[IMG:([^\\]]+)\\]\\](\\[/url\\])?")

	var last_end: int = 0
	for m in img_regex.search_all(remaining):
		var before: String = remaining.substr(last_end, m.get_start() - last_end)
		if before:
			content.append_text(before)

		var href: String = m.get_string(2)
		var src: String = _resolve_url(m.get_string(3), _current_url)

		if src in _image_textures:
			var tex: ImageTexture = _image_textures[src]
			var max_w: float = content.size.x if content.size.x > 0 else 600.0
			var w: float = minf(float(tex.get_width()), max_w)
			var h: float = float(tex.get_height()) * (w / float(tex.get_width()))
			if href:
				content.append_text("[url=%s]" % href)
				content.add_image(tex, int(w), int(h))
				content.append_text("[/url]")
			else:
				content.add_image(tex, int(w), int(h))
		else:
			if href:
				content.append_text("[url=%s]🔗[/url]" % href)

		last_end = m.get_end()

	var tail: String = remaining.substr(last_end)
	if tail:
		content.append_text(tail)
		
# ── Downloads ─────────────────────────────────────────────────────────────────


func _start_download(url: String) -> void:
	var filename: String = url.get_file()
	if filename.is_empty():
		filename = "download"
	
	status_label.text = "Downloading %s…" % filename
	
	var download_http: = HTTPRequest.new()
	download_http.use_threads = true
	download_http.timeout = 60.0
	add_child(download_http)
	download_http.set_meta("url", url)
	download_http.set_meta("filename", filename)
	download_http.request_completed.connect(_on_download_completed.bind(download_http))
	
	var headers: Array[String] = [
		"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
	]
	
	download_http.request(url, headers)


func _on_download_completed(
		result: int, code: int,
		_headers: PackedStringArray, body: PackedByteArray,
		download_http: HTTPRequest) -> void:
	var filename: String = download_http.get_meta("filename", "download")
	download_http.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.size() == 0:
		status_label.text = "Download failed: %s" % filename
		return
	
	# Save to GodotOS downloads folder.
	var save_path: String = "user://files/Downloads/" + filename
	DirAccess.make_dir_recursive_absolute("user://files/Downloads")
	
	var file: = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_buffer(body)
		file.close()
		status_label.text = "Downloaded: %s" % filename
		_show_download_toast(filename, save_path)
	else:
		status_label.text = "Save failed: %s" % filename


func _show_download_toast(filename: String, _path: String) -> void:
	# Show a small popup so the user knows where the file went.
	var toast: = Label.new()
	toast.text = "✓ Saved: %s" % filename
	toast.add_theme_color_override("font_color", Color.WHITE)
	toast.add_theme_stylebox_override("normal", _make_toast_style())
	toast.position = Vector2(8, content.size.y - 40)
	add_child(toast)
	
	# Auto-dismiss after 3 seconds.
	await get_tree().create_timer(3.0).timeout
	toast.queue_free()


func _make_toast_style() -> StyleBoxFlat:
	var style: = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.6, 0.2, 0.9)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


# ── Private helpers ───────────────────────────────────────────────────────────


# Returns true if the input looks like a search query rather than a URL.
# Bare words with no dots go to the search engine; "example.com" does not.
func _is_search_query(text: String) -> bool:
	if text.begins_with("http://") or text.begins_with("https://"):
		return false
	if "." in text and " " not in text:
		return false
	return true


# Ensures the URL has a scheme. Bare domains get https://, everything
# else is treated as a search query.
func _normalize_url(url: String) -> String:
	url = url.strip_edges()
	if url.begins_with("http://") or url.begins_with("https://"):
		return url
	if "." in url and " " not in url:
		return "https://" + url
	return "https://search.brave.com/search?q=" + url.uri_encode() + "&source=web"


# Resolves a potentially relative href against the current page URL.
# Absolute URLs are returned unchanged. Paths starting with "/" are
# resolved against the origin. Relative paths are resolved against
# the current directory.
func _resolve_url(href: String, base: String) -> String:
	if href.begins_with("http://") or href.begins_with("https://"):
		return href

	var regex: = RegEx.new()
	regex.compile("(https?://[^/]+)")
	var m: = regex.search(base)
	var origin: String = m.get_string(1) if m else ""

	if href.begins_with("/"):
		return origin + href

	var base_dir: String = base.substr(0, base.rfind("/") + 1)
	return base_dir + href


# Case-insensitive search for a specific response header value.
func _get_header(headers: PackedStringArray, key: String) -> String:
	for h in headers:
		if h.to_lower().begins_with(key.to_lower() + ":"):
			return h.substr(key.length() + 1).strip_edges()
	return ""


func _extract_title(html: String) -> String:
	var r: = RegEx.new()
	r.compile("(?i)<title[^>]*>(.*?)</title>")
	var m: = r.search(html)
	return m.get_string(1).strip_edges() if m else ""


func _set_loading(on: bool) -> void:
	loading_bar.visible = on
	refresh_btn.disabled = on


func _update_nav_buttons() -> void:
	back_btn.disabled = not history.can_go_back()
	forward_btn.disabled = not history.can_go_forward()


func _show_error(msg: String) -> void:
	content.bbcode_enabled = false
	content.text = "⚠ " + msg
	status_label.text = msg
	_set_loading(false)
	
func _create_context_menu() -> PopupMenu:
	var menu: = PopupMenu.new()
	add_child(menu)
	menu.add_item("Open Link",          0)
	menu.add_item("Open in New Tab",    1)
	menu.add_item("Copy Link",          2)
	menu.add_separator()
	menu.add_item("Save Image As…",     3)
	menu.add_separator()
	menu.add_item("Back",               4)
	menu.add_item("Forward",            5)
	menu.add_item("Refresh",            6)
	menu.id_pressed.connect(_on_context_menu_pressed)
	return menu

func _on_content_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_show_context_menu(get_global_mouse_position())


func _show_context_menu(pos: Vector2) -> void:
	_context_is_image = false
	_context_target_src = ""

	# Check if the hovered link points to an image.
	if _context_target_url != "":
		var ext: String = _context_target_url.get_file().get_extension().to_lower()
		if ext in ["png", "jpg", "jpeg", "gif", "svg", "webp", "ico"]:
			_context_is_image = true
			_context_target_src = _context_target_url

	# If not a link image, check if any loaded texture is near the cursor.
	if not _context_is_image and not _image_textures.is_empty():
		_context_is_image = true
		_context_target_src = _image_textures.keys()[0]

	# Update which items are enabled.
	var has_link: bool = _context_target_url != ""
	context_menu.set_item_disabled(context_menu.get_item_index(0), not has_link)
	context_menu.set_item_disabled(context_menu.get_item_index(1), not has_link)
	context_menu.set_item_disabled(context_menu.get_item_index(2), not has_link)
	context_menu.set_item_disabled(context_menu.get_item_index(3), not _context_is_image)

	context_menu.position = Vector2i(int(pos.x), int(pos.y))
	context_menu.popup()
	
func _on_context_menu_pressed(id: int) -> void:
	match id:
		0:  # Open Link
			if _context_target_url:
				navigate(_context_target_url)
		1:  # Open in New Tab
			if _context_target_url:
				# Signal up to the tab manager to open a new tab.
				# Adjust this to however your tab system opens URLs.
				get_parent().open_tab(_context_target_url)
		2:  # Copy Link
			if _context_target_url:
				DisplayServer.clipboard_set(_context_target_url)
				status_label.text = "Copied: %s" % _context_target_url
		3:  # Save Image As
			if _context_target_src:
				_save_image_from_cache(_context_target_src)
		4:  # Back
			_on_back()
		5:  # Forward
			_on_forward()
		6:  # Refresh
			_on_refresh()


func _save_image_from_cache(src: String) -> void:
	# If the texture is already in cache, save it directly without re-downloading.
	if src in _image_textures:
		var tex: ImageTexture = _image_textures[src]
		var img: Image = tex.get_image()
		var filename: String = src.get_file()
		if filename.is_empty() or not filename.contains("."):
			filename = "image.png"

		DirAccess.make_dir_recursive_absolute("user://files/Downloads")
		var save_path: String = "user://files/Downloads/" + filename

		var err: int = img.save_png(save_path)
		if err == OK:
			status_label.text = "Saved: %s" % filename
			_show_download_toast(filename, save_path)
		else:
			status_label.text = "Save failed: %s" % filename
	else:
		# Not in cache yet — download it fresh.
		_start_download(src)
	

func _on_meta_hover_started(meta: Variant) -> void:
	_context_target_url = _resolve_url(str(meta), _current_url)


func _on_meta_hover_ended(_meta: Variant) -> void:
	_context_target_url = ""
