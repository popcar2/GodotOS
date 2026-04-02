class_name HtmlParser
## Converts raw HTML into RichTextLabel BBCode.
##
## Pipeline:
##   1. Strip non-visible blocks (head, script, style, nav, footer)
##   2. Convert tables to BBCode [table] tags
##   3. Replace <svg> blocks and <img> tags with [[IMG:url]] placeholders
##   4. Convert formatting tags (bold, italic, links, etc.) to BBCode
##   5. Strip all remaining HTML tags
##   6. Decode HTML entities
##
## Image placeholders are resolved later by WebScript once textures are loaded.


# Matches <img src="..."> and extracts src + optional alt text.
# Also catches the first URL in <source srcset="..."> inside <picture> elements.
static func extract_images(html: String) -> Array[Dictionary]:
	var images: Array[Dictionary] = []

	var img_regex: = RegEx.new()
	img_regex.compile("<img\\s[^>]*src=[\"']([^\"']+)[\"'][^>]*(?:alt=[\"']([^\"']*)[\"'])?[^>]*>")
	for m in img_regex.search_all(html):
		images.append({
			"src": m.get_string(1),
			"alt": m.get_string(2) if m.get_string(2) != "" else "[image]",
			"placeholder": "[[IMG:%s]]" % m.get_string(1),
		})

	# <picture><source srcset="..."> — grab the first candidate URL only.
	# srcset can contain multiple URLs with descriptors like "img.png 2x",
	# so we stop at the first space or comma.
	var source_regex: = RegEx.new()
	source_regex.compile("<source[^>]*srcset=[\"']([^\"' ]+)[\"']")
	for m in source_regex.search_all(html):
		images.append({
			"src": m.get_string(1),
			"alt": "[picture]",
			"placeholder": "[[IMG:%s]]" % m.get_string(1),
		})

	return images


# Extracts inline <svg>...</svg> blocks and returns them as data URI entries
# so ImageLoader can decode them the same way as remote images.
# Skips SVGs under 100 chars — those are usually hidden icon sprites.
static func extract_inline_svgs(html: String) -> Array[Dictionary]:
	var images: Array[Dictionary] = []

	var svg_regex: = RegEx.new()
	svg_regex.compile("(?i)<svg[\\s\\S]*?</svg>")
	for m in svg_regex.search_all(html):
		var svg_text: String = m.get_string(0)
		if svg_text.length() < 100:
			continue
		var encoded: String = Marshalls.raw_to_base64(svg_text.to_utf8_buffer())
		var data_uri: String = "data:image/svg+xml;base64," + encoded
		images.append({
			"src": data_uri,
			"alt": "[svg]",
			"placeholder": "[[IMG:%s]]" % data_uri,
		})

	return images


# Tries to extract a hex background color from the page CSS.
# Checks the <body> inline style attribute first, then <style> blocks.
# Returns a hex string like "#ffffff", or "" if nothing was found.
static func extract_body_bg(html: String) -> String:
	var named_colors: Dictionary = {
		"white": "#ffffff", "black": "#000000", "red": "#ff0000",
		"green": "#008000", "blue": "#0000ff", "grey": "#808080",
		"gray": "#808080", "silver": "#c0c0c0", "yellow": "#ffff00",
		"orange": "#ffa500", "purple": "#800080", "pink": "#ffc0cb",
		"cyan": "#00ffff", "magenta": "#ff00ff", "lime": "#00ff00",
		"navy": "#000080", "teal": "#008080", "maroon": "#800000",
	}

	var r: = RegEx.new()

	# Check <body style="background-color: ..."> first.
	r.compile("(?i)<body[^>]*style=[\"'][^\"']*background(?:-color)?\\s*:\\s*(#[0-9a-fA-F]{3,6}|[a-zA-Z]+)")
	var m: = r.search(html)
	if m:
		var val: String = m.get_string(1).to_lower()
		return named_colors.get(val, val if val.begins_with("#") else "")

	# Fall back to searching inside each <style> block.
	# We extract the block contents first so the regex doesn't have to
	# cross tag boundaries in the full HTML string.
	var style_regex: = RegEx.new()
	style_regex.compile("(?i)<style[^>]*>([\\s\\S]*?)</style>")
	for sm in style_regex.search_all(html):
		var css: String = sm.get_string(1)

		# Allow arbitrary whitespace between "body" and "{" — minified CSS
		# puts them on the same line, pretty-printed CSS may not.
		var bg_regex: = RegEx.new()
		bg_regex.compile("(?i)body\\s*\\{[^}]*background(?:-color)?\\s*:\\s*(#[0-9a-fA-F]{3,6}|[a-zA-Z]+)")
		var bm: = bg_regex.search(css)
		if bm:
			var val: String = bm.get_string(1).to_lower()
			return named_colors.get(val, val if val.begins_with("#") else "")

	return ""


# Replaces <img src="url"> tags in HTML with [[IMG:url]] placeholders.
# These placeholders survive the tag stripper and are resolved to real
# textures later in WebScript._inject_content_with_textures().
static func inject_image_placeholders(html: String) -> String:
	var r: = RegEx.new()
	r.compile("<img\\s[^>]*src=[\"']([^\"']+)[\"'][^>]*>")
	for m in r.search_all(html):
		var src: String = m.get_string(1)
		html = html.replace(m.get_string(0), "[[IMG:%s]]" % src)
	return html


# Same as inject_image_placeholders but for inline <svg> blocks.
# The SVG markup is base64-encoded into a data URI so it can flow
# through the same ImageLoader pipeline as remote images.
static func inject_inline_svg_placeholders(html: String) -> String:
	var r: = RegEx.new()
	r.compile("(?i)<svg[\\s\\S]*?</svg>")
	for m in r.search_all(html):
		var svg_text: String = m.get_string(0)
		if svg_text.length() < 100:
			continue
		var encoded: String = Marshalls.raw_to_base64(svg_text.to_utf8_buffer())
		var data_uri: String = "data:image/svg+xml;base64," + encoded
		html = html.replace(svg_text, "[[IMG:%s]]" % data_uri)
	return html


# Main conversion entry point. Takes raw HTML and returns BBCode
# suitable for a RichTextLabel with bbcode_enabled = true.
static func to_bbcode(html: String) -> String:
	var text: String = html

	# Remove blocks that contribute no readable content.
	text = _strip_tag_block(text, "head")
	text = _strip_tag_block(text, "script")
	text = _strip_tag_block(text, "style")
	#text = _strip_tag_block(text, "nav")
	#text = _strip_tag_block(text, "aside")
	text = _strip_tag_block(text, "header")
	text = _strip_tag_block(text, "footer")
	text = _strip_tag_block(text, "figure")
	text = _strip_tag_block(text, "picture")
	text = _strip_tag_block(text, "noscript")
	text = _strip_tag_block(text, "dialog")
	text = _strip_tag_block(text, "template")

	# Strip HTML comments — <!-- ... -->
	var comment_regex: = RegEx.new()
	comment_regex.compile("<!--[\\s\\S]*?-->")
	text = comment_regex.sub(text, "", true)

	# Convert tables before other processing so their inner tags
	# don't get mangled by the generic tag replacements below.
	text = _convert_tables(text)

	# Inject image placeholders before link processing so that
	# <a href="..."><img src="..."></a> becomes a clickable image
	# rather than a broken link with an empty label.
	text = inject_inline_svg_placeholders(text)

	# Strip tiny images that are decorative — width/height under 64px.
	# These are favicons, avatars, and UI icons that clutter text flow.
	var tiny_img_regex: = RegEx.new()
	tiny_img_regex.compile("<img[^>]*(?:width|height)=[\"']?([0-9]+)[\"']?[^>]*>")
	for m in tiny_img_regex.search_all(text):
		var size: int = m.get_string(1).to_int()
		if size > 0 and size <= 16:
			text = text.replace(m.get_string(0), "")

	text = inject_image_placeholders(text)

	# Block-level elements — add line breaks at closing tags.
	text = text.replace("</p>", "\n\n")
	text = text.replace("</div>", "")
	text = text.replace("</li>", "\n")
	text = text.replace("<br>", "\n")
	text = text.replace("<br/>", "\n")
	text = text.replace("<br />", "\n")
	text = text.replace("</section>", "\n")
	text = text.replace("</article>", "\n")

	# Headings — close with bold off + blank line.
	text = text.replace("</h1>", "[/b]\n\n")
	text = text.replace("</h2>", "[/b]\n\n")
	text = text.replace("</h3>", "[/b]\n\n")
	text = text.replace("</h4>", "[/b]\n\n")

	# Inline formatting tags.
	text = _replace_tag(text, "h1",     "[b]",    "")
	text = _replace_tag(text, "h2",     "[b]",    "")
	text = _replace_tag(text, "h3",     "[b]",    "")
	text = _replace_tag(text, "h4",     "[b]",    "")
	text = _replace_tag(text, "strong", "[b]",    "[/b]")
	text = _replace_tag(text, "b",      "[b]",    "[/b]")
	text = _replace_tag(text, "em",     "[i]",    "[/i]")
	text = _replace_tag(text, "i",      "[i]",    "[/i]")
	text = _replace_tag(text, "u",      "[u]",    "[/u]")
	text = _replace_tag(text, "code",   "[code]", "[/code]")
	text = _replace_tag(text, "li",     "• ",     "")

	# Inline color — only match spans that actually contain a closing tag
	# so we can pair [color] and [/color] without leaking orphan close tags.
	var color_regex: = RegEx.new()
	color_regex.compile("(?i)<span[^>]*style=[\"'][^\"']*color\\s*:\\s*(#[0-9a-fA-F]{3,6})[^\"']*[\"'][^>]*>([\\s\\S]*?)</span>")
	for m in color_regex.search_all(text):
		text = text.replace(m.get_string(0),
			"[color=%s]%s[/color]" % [m.get_string(1), m.get_string(2)])

	# Strip any remaining spans that had no color — don't emit [/color] for them.
	text = text.replace("</span>", "")

	# Legacy <font color="..."> tags.
	var font_regex: = RegEx.new()
	font_regex.compile("(?i)<font[^>]*color=[\"'](#[0-9a-fA-F]{3,6})[\"'][^>]*>([\\s\\S]*?)</font>")
	for m in font_regex.search_all(text):
		text = text.replace(m.get_string(0),
			"[color=%s]%s[/color]" % [m.get_string(1), m.get_string(2)])
	text = text.replace("</font>", "")

	# Links — three cases:
	#   1. Link wraps an image placeholder → keep placeholder as label
	#   2. Link has no visible label (icon-only link) → show a 🔗 glyph
	#   3. Normal text link
	var link_regex: = RegEx.new()
	link_regex.compile("<a\\s[^>]*href=[\"']([^\"']+)[\"'][^>]*>([\\s\\S]*?)</a>")
	for m in link_regex.search_all(text):
		var href: String = m.get_string(1)
		var label: String = m.get_string(2).strip_edges()
		if label.begins_with("[[IMG:"):
			text = text.replace(m.get_string(0),
				"[url=%s]%s[/url]" % [href, label])
		elif label.is_empty():
			text = text.replace(m.get_string(0),
				"[url=%s][color=#88aaff][u]🔗[/u][/color][/url]" % href)
		else:
			text = text.replace(m.get_string(0),
				"[url=%s][color=#88aaff][u]%s[/u][/color][/url]" % [href, label])

	# Strip every remaining HTML tag. By this point all the ones we
	# care about have been converted to BBCode or placeholders.
	var tag_regex: = RegEx.new()
	tag_regex.compile("<[^>]+>")
	text = tag_regex.sub(text, "", true)

	# Decode the most common HTML entities.
	text = text.replace("&amp;",   "&")
	text = text.replace("&lt;",    "<")
	text = text.replace("&gt;",    ">")
	text = text.replace("&quot;",  "\"")
	text = text.replace("&#39;",   "'")
	text = text.replace("&nbsp;",  " ")
	text = text.replace("&raquo;", "»")
	text = text.replace("&laquo;", "«")
	text = text.replace("&mdash;", "—")
	text = text.replace("&ndash;", "–")
	text = text.replace("&hellip;","…")
	text = text.replace("&copy;",  "©")
	text = text.replace("&reg;",   "®")
	text = text.replace("&trade;", "™")
	text = text.replace("&euro;",  "€")
	text = text.replace("&pound;", "£")

	# Remove lines that are nothing but whitespace — these come from
	# gutted div containers that held CSS background images or layout boxes.
	var empty_line_regex: = RegEx.new()
	empty_line_regex.compile("(?m)^[ \\t]+$")
	text = empty_line_regex.sub(text, "", true)

	# Collapse runs of 3+ newlines down to a single blank line.
	var blank_regex: = RegEx.new()
	blank_regex.compile("\\n{3,}")
	text = blank_regex.sub(text, "\n\n", true)

	return text.strip_edges()


# ── Private helpers ───────────────────────────────────────────────────────────


# Converts <table> blocks to RichTextLabel [table] BBCode.
# Counts columns from the first row so the table tag gets the right width.
static func _convert_tables(text: String) -> String:
	var table_regex: = RegEx.new()
	table_regex.compile("(?i)<table[\\s\\S]*?</table>")

	for tm in table_regex.search_all(text):
		var table_html: String = tm.get_string(0)
		var result: String = ""

		# Count <td>/<th> cells in the first <tr> to determine column count.
		var cell_count_regex: = RegEx.new()
		cell_count_regex.compile("(?i)<t[dh][^>]*>")
		var first_row_regex: = RegEx.new()
		first_row_regex.compile("(?i)<tr[^>]*>([\\s\\S]*?)</tr>")
		var first_row: = first_row_regex.search(table_html)
		var col_count: int = 1
		if first_row:
			col_count = max(cell_count_regex.search_all(first_row.get_string(1)).size(), 1)

		result += "[table=%d]\n" % col_count

		var row_regex: = RegEx.new()
		row_regex.compile("(?i)<tr[^>]*>([\\s\\S]*?)</tr>")
		var cell_regex: = RegEx.new()
		cell_regex.compile("(?i)<t([dh])[^>]*>([\\s\\S]*?)</t[dh]>")
		var inner_tag_regex: = RegEx.new()
		inner_tag_regex.compile("<[^>]+>")

		for row in row_regex.search_all(table_html):
			for cell in cell_regex.search_all(row.get_string(1)):
				var is_header: bool = cell.get_string(1).to_lower() == "h"
				# Strip tags inside cells — handled as plain text for now.
				var cell_content: String = inner_tag_regex.sub(
					cell.get_string(2).strip_edges(), "", true)
				if is_header:
					result += "[cell][b]%s[/b][/cell]\n" % cell_content
				else:
					result += "[cell]%s[/cell]\n" % cell_content

		result += "[/table]\n"
		text = text.replace(table_html, result)

	return text


# Removes an entire tag block including its contents, e.g. <script>...</script>.
static func _strip_tag_block(text: String, tag: String) -> String:
	var r: = RegEx.new()
	r.compile("(?i)<" + tag + "[^>]*>[\\s\\S]*?</" + tag + ">")
	return r.sub(text, "", true)


# Replaces opening tags (with any attributes) with open_bb
# and closing tags with close_bb. Case-insensitive.
static func _replace_tag(
		text: String, tag: String, open_bb: String, close_bb: String) -> String:
	var r: = RegEx.new()
	r.compile("(?i)<" + tag + "(\\s[^>]*)?>")
	text = r.sub(text, open_bb, true)
	text = text.replace("</" + tag + ">", close_bb)
	text = text.replace("</" + tag.to_upper() + ">", close_bb)
	return text
