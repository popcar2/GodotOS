extends Panel

class_name GodotrisPieceHolder

var current_piece: GodotrisPiece = null

func swap_piece(new_piece: GodotrisPiece) -> GodotrisPiece:
	var tmp := current_piece
	current_piece = new_piece
	
	add_child(current_piece)
	current_piece.position = current_piece.container_offset
	
	return tmp
