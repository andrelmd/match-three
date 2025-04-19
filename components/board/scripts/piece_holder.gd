class_name PieceHolder extends Holder

func set_in_position(node: Piece, cell_position: Vector2i) -> void:
	return super(node, cell_position)

func get_in_position(cell_position: Vector2i) -> Piece:
	return super(cell_position)
	
