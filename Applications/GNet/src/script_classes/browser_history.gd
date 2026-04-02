class_name BrowserHistory
## Tracks visited URLs and supports back/forward navigation.
##
## Works like a stack with a movable cursor. Pushing a new URL while
## the cursor is mid-history discards everything ahead of it, matching
## standard browser behaviour (go back, click a link, forward is gone).


var _history: Array[String] = []
var _index: int = -1


func push(url: String) -> void:
	# Discard forward history when navigating to a new page.
	if _index < _history.size() - 1:
		_history = _history.slice(0, _index + 1)
	_history.append(url)
	_index = _history.size() - 1


func can_go_back() -> bool:
	return _index > 0


func can_go_forward() -> bool:
	return _index < _history.size() - 1


func go_back() -> String:
	if can_go_back():
		_index -= 1
	return current()


func go_forward() -> String:
	if can_go_forward():
		_index += 1
	return current()


func current() -> String:
	if _index >= 0 and _index < _history.size():
		return _history[_index]
	return ""
