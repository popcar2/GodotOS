extends Control

class_name GodotrisGame

@export var start_menu: CanvasItem
@export var end_menu: CanvasItem
@export var countdown_timer: Timer
@export var countdown_label: Label
@export var score_label: Label
@export var level_label: Label
@export var lines_label: Label
@export var piece_spawner: GodotrisPieceSpawner
@export var input_handler: GodotrisInputHandler
@export var grid: GodotrisGrid

const level_droptimes: Array[int] = [
	16 * 48,
	16 * 43,
	16 * 38,
	16 * 33,
	16 * 28,
	16 * 23,
	16 * 18,
	16 * 13,
	16 * 8,
	16 * 6,
	16 * 5,
	16 * 5,
	16 * 5,
	16 * 4,
	16 * 4,
	16 * 4,
	16 * 3,
	16 * 3,
	16 * 3,
	16 * 2,
	16 * 2,
	16 * 2,
	16 * 2,
	16 * 2,
	16 * 2,
	16 * 2,
	16 * 2,
	16 * 2,
	16 * 2,
	16 * 1
]

var ticks_left := 3
var current_score := 0
var current_level := 0
var lines_cleared := 0
var total_lines_cleared := 0

func start_game() -> void:
	grid.clear_all_blocks()
	piece_spawner.initialize()
	start_menu.hide()
	end_menu.hide()
	ticks_left = 3
	current_score = 0
	current_level = 0
	lines_cleared = 0
	total_lines_cleared = 0
	update_score()
	update_level()
	update_lines()
	countdown_label.show()
	countdown_label.text = str(ticks_left)
	countdown_timer.start()

func end_game() -> void:
	end_menu.show()

func on_timer_tick() -> void:
	ticks_left -= 1
	countdown_label.text = str(ticks_left)
	if ticks_left == 0:
		countdown_label.text = "Start!"
		countdown_label.hide()
		countdown_timer.stop()
		input_handler.request_piece()

func on_piece_placed(count: int) -> void:
	if count == 0:
		return
	
	var addition: int
	match count:
		1:
			addition = 40
		2:
			addition = 100
		3:
			addition = 300
		4:
			addition = 1200
	
	addition *= current_level + 1
	current_score += addition
	lines_cleared += count
	total_lines_cleared += count
	update_lines()
	update_score()
	if lines_cleared >= 10:
		lines_cleared -= 10
		current_level += 1
		update_level()

func on_piece_softdropped() -> void:
	current_score += 1
	update_score()

func update_score() -> void:
	score_label.text = "Score: " + str(current_score)

func update_level() -> void:
	level_label.text = "Level: " + str(current_level)
	input_handler.update_droptime(level_droptimes[current_level])

func update_lines() -> void:
	lines_label.text = "Lines cleared: " + str(total_lines_cleared)
