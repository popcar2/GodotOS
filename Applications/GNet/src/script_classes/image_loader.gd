class_name ImageLoader
extends Node
## Downloads and decodes images from URLs or inline data URIs.
##
## Each image gets its own HTTPRequest node so downloads run in parallel
## with no risk of one cancelling another. Completed textures are cached
## by URL so the same image is never fetched twice within a session.
##
## Signals:
##   image_ready  — emitted each time a single image finishes loading
##   all_done     — emitted when every image in the current batch is done


signal image_ready(src: String, texture: ImageTexture)
signal all_done


var _cache: Dictionary = {}
var _pending: int = 0

# Sent with every image request. The User-Agent makes servers treat us
# like a real browser — many CDNs reject requests without one.
var _base_headers: Array[String] = [
	"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
	"Accept: image/webp,image/png,image/jpeg,image/*,*/*;q=0.8",
]


# Starts fetching all URLs in srcs. Skips cached entries and handles
# data URIs locally without making a network request.
# referer should be the URL of the page that contains these images —
# some CDNs (e.g. Wikimedia) reject requests with a mismatched or absent Referer.
func fetch_all(srcs: Array[String], referer: String = "") -> void:
	var to_fetch: Array[String] = []

	for src in srcs:
		if src in _cache:
			continue
		if src.begins_with("data:"):
			_decode_data_uri(src)
		else:
			to_fetch.append(src)

	if to_fetch.is_empty():
		if _pending <= 0:
			all_done.emit()
		return

	_pending += to_fetch.size()
	for src in to_fetch:
		_fetch_one(src, referer)


func get_cached(src: String) -> ImageTexture:
	return _cache.get(src, null)


# ── Private ───────────────────────────────────────────────────────────────────


# Decodes a data: URI without a network request.
# Supports base64-encoded and plain-text (URL-encoded) SVG data URIs.
func _decode_data_uri(src: String) -> void:
	var comma: int = src.find(",")
	if comma == -1:
		return

	# The header is everything between "data:" and the comma, e.g. "image/png;base64"
	var header: String = src.substr(5, comma - 5)

	# GIF and ICO data URIs aren't worth decoding — skip them silently.
	if "gif" in header or "ico" in header:
		return

	var raw: PackedByteArray
	if "base64" in header:
		raw = Marshalls.base64_to_raw(src.substr(comma + 1))
	else:
		# Plain-text SVG — the data portion is URL-encoded UTF-8.
		raw = src.substr(comma + 1).uri_decode().to_utf8_buffer()

	if raw.size() == 0:
		return

	var img: = Image.new()
	if _sniff_and_load(img, raw, header) == OK:
		var tex: = ImageTexture.create_from_image(img)
		_cache[src] = tex
		image_ready.emit(src, tex)


# Spawns a dedicated HTTPRequest node for a single image URL.
# The node frees itself after the response arrives.
func _fetch_one(src: String, referer: String = "") -> void:
	if src.length() < 10 or not (src.begins_with("http://") or src.begins_with("https://")):
		#print("IMG skipped invalid URL: ", src)
		_pending -= 1
		if _pending <= 0:
			all_done.emit()
		return

	#print("IMG fetching: ", src)

	var http: = HTTPRequest.new()
	http.use_threads = true
	http.timeout = 10.0
	add_child(http)
	http.set_meta("src", src)
	http.request_completed.connect(_on_image_fetched.bind(http))

	var headers: Array[String] = _base_headers.duplicate()
	if referer:
		headers.append("Referer: " + referer)

	var err: = http.request(src, headers)
	if err != OK:
		#print("IMG request error: ", src)
		http.queue_free()
		_pending -= 1
		if _pending <= 0:
			all_done.emit()


func _on_image_fetched(
		result: int, code: int,
		headers: PackedStringArray, body: PackedByteArray,
		http: HTTPRequest) -> void:
	var src: String = http.get_meta("src", "")
	http.queue_free()

	# Extract Content-Type so we can pick the right decoder.
	var content_type: String = ""
	for h in headers:
		if h.to_lower().begins_with("content-type:"):
			content_type = h.substr(13).strip_edges().to_lower()
			break

	#print("IMG response | src: %s | code: %d | type: %s | bytes: %d" % [
	#	src, code, content_type, body.size()])

	if result == HTTPRequest.RESULT_SUCCESS and code == 200 and body.size() > 0:
		var img: = Image.new()
		if _sniff_and_load(img, body, content_type) == OK:
			var tex: = ImageTexture.create_from_image(img)
			_cache[src] = tex
			image_ready.emit(src, tex)

	_pending -= 1
	if _pending <= 0:
		all_done.emit()


# Picks the right Image decoder based on Content-Type, then falls back
# to magic byte sniffing if the type is missing or generic.
func _sniff_and_load(img: Image, body: PackedByteArray, content_type: String) -> Error:
	# SVG — Godot rasterizes these natively via its bundled NanoSVG library.
	if "svg" in content_type:
		return img.load_svg_from_buffer(body, 1.0)

	if "gif" in content_type:
		return _try_gif(img, body)

	if "ico" in content_type:
		return _try_ico(img, body)

	# AVIF has no Godot decoder — skip silently.
	if "avif" in content_type:
		return ERR_INVALID_DATA

	if "png" in content_type:
		return img.load_png_from_buffer(body)
	if "jpeg" in content_type or "jpg" in content_type:
		return img.load_jpg_from_buffer(body)
	if "webp" in content_type:
		return img.load_webp_from_buffer(body)

	# Content-Type missing or unhelpful — inspect the first few bytes.
	if body.size() < 4:
		return ERR_INVALID_DATA

	# SVG is XML and starts with '<' (0x3C).
	if body[0] == 0x3C:
		return img.load_svg_from_buffer(body, 1.0)
	# PNG magic: 89 50 4E 47
	if body[0] == 0x89 and body[1] == 0x50:
		return img.load_png_from_buffer(body)
	# JPEG magic: FF D8 FF
	if body[0] == 0xFF and body[1] == 0xD8:
		return img.load_jpg_from_buffer(body)
	# WebP magic: RIFF....WEBP
	if body[0] == 0x52 and body[1] == 0x49 and body.size() > 12 \
			and body[8] == 0x57 and body[9] == 0x45:
		return img.load_webp_from_buffer(body)

	return ERR_INVALID_DATA


# GIF decoding isn't supported by Godot at runtime.
# We verify the magic bytes and return a 1x1 grey placeholder so the
# image slot isn't completely empty in the rendered page.
func _try_gif(img: Image, body: PackedByteArray) -> Error:
	# GIF87a and GIF89a both start with "GIF" (47 49 46).
	if body.size() < 6 or body[0] != 0x47 or body[1] != 0x49 or body[2] != 0x46:
		return ERR_INVALID_DATA
	img.set_data(1, 1, false, Image.FORMAT_RGB8, PackedByteArray([180, 180, 180]))
	return OK


# Modern ICO files embed a full PNG after a small directory header.
# The image data offset is stored as a little-endian uint32 at bytes 18–21.
func _try_ico(img: Image, body: PackedByteArray) -> Error:
	if body.size() < 22:
		return ERR_INVALID_DATA
	var offset: int = body[18] | (body[19] << 8) | (body[20] << 16) | (body[21] << 24)
	if offset >= body.size():
		return ERR_INVALID_DATA
	return img.load_png_from_buffer(body.slice(offset))
