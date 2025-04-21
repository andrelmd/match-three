class_name BoardSlideDownState extends State

@export var board: Board
@export var piece_holder: PieceHolder
@export var slide_down_timer: Timer
@export var slided_down_pieces_next_state: State


func enter() -> void:
	slide_down_timer.start()
	await  slide_down_timer.timeout
	await _slide_pieces_down()
	finished.emit(slided_down_pieces_next_state.name)

func _slide_pieces_down() -> void:
	for width in range(board.max_width):
		for height in range(board.max_height - 1, -1, -1):
			var cell_fill_coordinate = Vector2i(width, height)
			if not piece_holder.is_coordinate_null(cell_fill_coordinate):
				continue
				
			if board._is_position_restricted_fill(cell_fill_coordinate):
				continue
				
			for height_offset in range(height - 1, -1, -1):
				var piece_cell_coordinate = Vector2i(width, height_offset)
				if piece_holder.is_coordinate_null(piece_cell_coordinate):
					continue
				
				if board._is_position_restricted_fill(piece_cell_coordinate):
					continue
				
				var piece = piece_holder.get_in_coordinate(piece_cell_coordinate)
				piece_holder.set_in_coordinate(piece, cell_fill_coordinate)
				piece_holder.set_null_in_coordinate(piece_cell_coordinate)
				await piece.move(board.grid_to_pixel(cell_fill_coordinate))
				break
