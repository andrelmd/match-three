class_name MatchAllInRow extends SkillStrategy

func execute(board: Board, piece: Piece) -> void:
	var cell_coordinate = board.piece_holder.find_coordinate(piece)
	var height = cell_coordinate.y
	for width in board.max_width:
		var board_piece = board.piece_holder.get_in_coordinate(Vector2i(width, height))
		if board_piece == null:
			continue
		
		if board_piece == piece:
			continue
		
		if board_piece.matched:
			continue
		
		board_piece.matched = true
