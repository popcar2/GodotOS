extends Node

class_name GodotrisInputHandler

@export var das := 167
@export var arr := 33
@export var sdf := 5
@export var piece_spawner: GodotrisPieceSpawner
@export var grid: GodotrisGrid

enum DasStatus {
	Inactive,
	Left,
	LeftCharging,
	Right,
	RightCharging
}

const MAX_INT := 9223372036854775807

signal piece_softdropped

var active_piece: GodotrisPiece
var normal_drop_time: int
var drop_time: int
var last_drop := MAX_INT
var last_move := MAX_INT
var das_status := DasStatus.Inactive

func stop_control() -> void:
	active_piece = null

func on_piece_placed(_lines_cleared: int = 0) -> void:
	request_piece()

func update_droptime(new_value: int) -> void:
	if normal_drop_time == drop_time:
		drop_time = new_value
	else:
		@warning_ignore("integer_division")
		drop_time = max(new_value / sdf, 16)
	
	normal_drop_time = new_value

func request_piece() -> void:
	active_piece = piece_spawner.spawn_new_piece()
	last_drop = Time.get_ticks_msec()

func _input(event: InputEvent) -> void:
	var action_time := Time.get_ticks_msec()
	if !(event is InputEventKey):
		return
		
	match event.keycode:
		KEY_SPACE:
			if !event.is_pressed() or active_piece == null:
				return
			
			var movement := Vector2i.UP
			while grid.can_place(active_piece, movement):
				movement += Vector2i.UP
			movement -= Vector2i.UP
			
			active_piece.position += Vector2.DOWN * grid.BLOCK_SIZE * (-movement.y)
			var tmp := active_piece
			stop_control()
			grid.place(tmp)
		KEY_DOWN:
			if event.is_pressed():
				# if softdrop is activated already, we need to return
				# because otherwise droptime is set more often than it should
				if drop_time != normal_drop_time:
					return
				@warning_ignore("integer_division")
				drop_time = max(normal_drop_time / sdf, 16)
				last_drop = action_time - drop_time
			else:
				drop_time = normal_drop_time
				last_drop = action_time
		KEY_UP:
			if event.is_pressed() and active_piece != null:
				active_piece.rotate(PI / 2)
				if !grid.can_place(active_piece):
					active_piece.rotate(-PI / 2)
		KEY_RIGHT:
			if event.is_pressed():
				if das_status == DasStatus.RightCharging or das_status == DasStatus.Right:
					return
				das_status = DasStatus.RightCharging
				last_move = action_time
				
				if active_piece != null:
					if grid.can_place(active_piece, Vector2i.RIGHT):
						active_piece.position += Vector2.RIGHT * grid.BLOCK_SIZE
			else:
				das_status = DasStatus.Inactive
				last_move = MAX_INT
		KEY_LEFT:
			if event.is_pressed():
				if das_status == DasStatus.LeftCharging or das_status == DasStatus.Left:
					return
				das_status = DasStatus.LeftCharging
				last_move = action_time
				
				if active_piece != null:
					if grid.can_place(active_piece, Vector2i.LEFT):
						active_piece.position += Vector2.LEFT * grid.BLOCK_SIZE
			else:
				das_status = DasStatus.Inactive
				last_move = MAX_INT

func _process(_delta: float) -> void:
	var process_time := Time.get_ticks_msec()
	if active_piece == null:
		return
	
	handle_gravity(process_time)
	handle_das(process_time)

func handle_gravity(process_time: int) -> void:
	while process_time >= last_drop + drop_time:
		# i have to reverse the vertical vector since godot has directions messed up
		if grid.can_place(active_piece, Vector2i.UP):
			active_piece.position += Vector2.DOWN * grid.BLOCK_SIZE
			last_drop = last_drop + drop_time
			if drop_time != normal_drop_time:
				piece_softdropped.emit()
		else:
			var tmp := active_piece
			stop_control()
			grid.place(tmp)
			break

func handle_das(time: int) -> void:
	match das_status:
		DasStatus.RightCharging:
			if time >= last_move + das:
				das_status = DasStatus.Right
				last_move += das
				handle_das(time)
		DasStatus.LeftCharging:
			if time >= last_move + das:
				das_status = DasStatus.Left
				last_move += das
				handle_das(time)
		DasStatus.Right:
			while time >= last_move + arr:
				last_move += arr
				if grid.can_place(active_piece, Vector2i.RIGHT):
					active_piece.position += Vector2i.RIGHT * grid.BLOCK_SIZE
		DasStatus.Left:
			while time >= last_move + arr:
				last_move += arr
				if grid.can_place(active_piece, Vector2i.LEFT):
					active_piece.position += Vector2i.LEFT * grid.BLOCK_SIZE
		DasStatus.Inactive:
			pass











