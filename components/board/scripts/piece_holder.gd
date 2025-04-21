class_name PieceHolder extends Holder

func set_in_coordinate(node: Piece, cell_position: Vector2i) -> void:
	return super(node, cell_position)

func get_in_coordinate(cell_position: Vector2i) -> Piece:
	return super(cell_position)

func find_coordinate(piece: Piece) -> Vector2i:
	return super(piece)
