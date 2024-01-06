extends OptionButton

func _ready() -> void:
	var index: int
	match Engine.max_fps:
		30: index = 0
		60: index = 1
		90: index = 2
		120: index = 3
		144: index = 4
		165: index = 5
		240: index = 6
		360: index = 7
	
	selected = index

func _on_item_selected(index: int) -> void:
	var new_fps: int
	match index:
		0: new_fps = 30
		1: new_fps = 60
		2: new_fps = 90
		3: new_fps = 120
		4: new_fps = 144
		5: new_fps = 165
		6: new_fps = 240
		7: new_fps = 360
	
	Engine.max_fps = new_fps
