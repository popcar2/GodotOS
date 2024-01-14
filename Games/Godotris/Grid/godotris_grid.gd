extends Control

class_name GodotrisGrid

@export var grid_dimensions: Vector2i = Vector2i(10, 20)

const BLOCK_SIZE = 32.0

signal piece_placed(lines_cleared: int)

var blocks: Array[Array] = []

func clear_all_blocks() -> void:
	for line: Array in blocks:
		for block: GodotrisBlock in line:
			if block != null:
				block.clear()
	
	blocks.clear()

func local_to_grid(pos: Vector2) -> Vector2i:
	pos /= BLOCK_SIZE
	var grid_pos := Vector2i(floor(pos.x), floor(pos.y))
	grid_pos.y -= grid_dimensions.y - 1
	grid_pos.y = -grid_pos.y
	return grid_pos

func position_empty(pos: Vector2, offset := Vector2i()) -> bool:
	var grid_pos := local_to_grid(pos) + offset
	
	if grid_pos.x < 0 or grid_pos.x >= grid_dimensions.x or grid_pos.y < 0:
		return false
	
	if blocks.size() <= grid_pos.y:
		return true
	
	return blocks[grid_pos.y][grid_pos.x] == null

func can_place(piece: GodotrisPiece, offset := Vector2i()) -> bool:
	for block: GodotrisBlock in piece.get_children():
		if !position_empty(block.global_position - global_position, offset):
			return false
		
	return true

func place(piece: GodotrisPiece) -> void:
	for block: GodotrisBlock in piece.get_children():
		var grid_pos := local_to_grid(block.global_position - global_position)
		
		while blocks.size() <= grid_pos.y:
			blocks.append([])
			for i: int in range(grid_dimensions.x):
				blocks[blocks.size() - 1].append(null)
		
		blocks[grid_pos.y][grid_pos.x] = block
	
	check_and_clear_lines()

func check_and_clear_lines() -> void:
	var i := blocks.size()
	var lines_to_clear: Array[int] = []
	while i >= 0:
		i -= 1
		var line: Array = blocks[i]
		var is_full := true
		for pos: GodotrisBlock in line:
			if pos == null:
				is_full = false
				break
		
		if !is_full:
			continue
		
		lines_to_clear.append(i)
	
	if lines_to_clear.size() > 0:
		clear_lines(lines_to_clear)
	
	piece_placed.emit(lines_to_clear.size())

func clear_lines(lines: Array[int]) -> void:
	@warning_ignore("integer_division")
	var end_index := grid_dimensions.x / 2
	var start_index := end_index - 1
	
	while start_index >= 0:
		for line_index: int in lines:
			blocks[line_index][start_index].clear()
			blocks[line_index][end_index].clear()
			
		start_index -= 1
		end_index += 1
		var timer := get_tree().create_timer(0.05)
		await timer.timeout
	
	for line_index: int in lines:
		blocks.remove_at(line_index)
		for y: int in range(line_index, blocks.size()):
			for block: GodotrisBlock in blocks[y]:
				if block == null:
					continue
				block.global_position += Vector2.DOWN * BLOCK_SIZE
