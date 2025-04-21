class_name CreateBombStrategy extends SkillStrategy

enum BombType {
	ROW,
	COLUMN,
	ADJACENT
}

func execute(board: Board, piece: Piece) -> void:
	var matches = board.find_matches()
	if (
		(matches.has(board.first_piece_movement) or matches.has(board.second_piece_movement)) 
		and not (piece == board.first_piece_movement or piece == board.second_piece_movement)
		):
		return
	
	var piece_cell_coordinate = board.piece_holder.find_coordinate(piece)
	var current_row_match_streak = board.get_quantity_horizontal_match(piece_cell_coordinate, piece.piece_type)
	var current_column_match_streak = board.get_quantity_vertical_match(piece_cell_coordinate, piece.piece_type)
	
	var max_row_match_streak = 0
	var max_column_match_streak = 0
	
	for match_piece in matches:
		var match_piece_cell_coordinate = board.piece_holder.find_coordinate(match_piece)
		var match_piece_row_streak = board.get_quantity_horizontal_match(match_piece_cell_coordinate, match_piece.piece_type)
		var match_piece_column_streak = board.get_quantity_vertical_match(match_piece_cell_coordinate, match_piece.piece_type)
		
		if max_row_match_streak < match_piece_row_streak:
			max_row_match_streak = match_piece_row_streak
		
		if max_column_match_streak < match_piece_column_streak:
			max_column_match_streak = match_piece_column_streak
		
	
	if (piece == board.first_piece_movement):
		if max_column_match_streak >= 4:
			make_bomb(piece, BombType.ROW)
			return
	
		if max_row_match_streak >= 4:
			make_bomb(piece, BombType.COLUMN)
			return
	
	if (piece == board.second_piece_movement):
		if max_column_match_streak >= 4:
			make_bomb(piece, BombType.ROW)
			return
	
		if max_row_match_streak >= 4:
			make_bomb(piece, BombType.COLUMN)
			return
	
	
	if current_row_match_streak < max_row_match_streak or current_column_match_streak < max_column_match_streak:
		return
	
	if current_column_match_streak >= 4:
		make_bomb(piece, BombType.ROW)
		return
	
	if current_row_match_streak >= 4:
		make_bomb(piece, BombType.COLUMN)
		return

func make_bomb(piece: Piece, bomb_type: BombType) -> void:
	piece.skills.clear()
	piece.skills.append(CreateBombStrategy.new())
	piece.matched = false
	match(bomb_type):
		BombType.ROW:
			piece.skills.append(MatchAllInRow.new())
			piece.piece_sprite.modulate = Color(1, 1, 0, 1)
			
		BombType.COLUMN:
			piece.skills.append(MatchAllInColumn.new())
			piece.piece_sprite.modulate = Color(0, 1, 1, 1)
			
			
