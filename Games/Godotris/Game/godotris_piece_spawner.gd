extends Node

class_name GodotrisPieceSpawner

@export var previews: Array[GodotrisPieceHolder]
@export var pieces: Dictionary
@export var grid: GodotrisGrid

signal cant_spawn

var available_pieces: Array[String] = ["i", "s", "z", "o", "j", "l", "t"]
var current_pieces: Array[String] = ["i", "s", "z", "o", "j", "l", "t"]

# implementation of the 7-bag randomizer
func get_random_piece() -> PackedScene:
	if current_pieces.is_empty():
		current_pieces.append_array(available_pieces)
	
	var piece_name: String = current_pieces.pick_random()
	current_pieces.erase(piece_name)
	
	return pieces[piece_name]

func add_to_previews(new_piece: GodotrisPiece) -> GodotrisPiece:
	for preview in previews:
		new_piece = preview.swap_piece(new_piece)
	
	return new_piece

func initialize() -> void:
	for preview in previews:
		var new_piece_scn := get_random_piece()
		var new_piece: GodotrisPiece = new_piece_scn.instantiate()
		var old_piece := preview.swap_piece(new_piece)
		if old_piece != null:
			old_piece.queue_free()

func spawn_new_piece() -> GodotrisPiece:
	var new_piece := add_to_previews(get_random_piece().instantiate())
	
	new_piece.reparent(grid)
	new_piece.position = new_piece.spawn_offset
	if !grid.can_place(new_piece):
		cant_spawn.emit()
		new_piece.queue_free()
		return null
	
	return new_piece
