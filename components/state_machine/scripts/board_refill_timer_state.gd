class_name BoardRefillTimerState extends State

@export var board: Board
@export var piece_holder: PieceHolder
@export var refill_timer: Timer
@export var has_refilled_next_state: State

func enter() -> void:
	refill_timer.start()
	await refill_timer.timeout
	await _refill_pieces()
	finished.emit(has_refilled_next_state.name)

func _refill_pieces() -> void:
	for width in board.max_width:
		for height in board.max_height:
			var cell_coordinate = Vector2i(width, height)
			if not piece_holder.is_coordinate_null(cell_coordinate):
				continue
			if board._is_position_restricted_fill(cell_coordinate):
				continue
			var new_piece = board._create_piece(randi() % board.possible_pieces.size(), cell_coordinate)
			await new_piece.move(board.grid_to_pixel(cell_coordinate))
