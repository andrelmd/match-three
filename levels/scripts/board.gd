extends Node2D

@export var width: int = 8
@export var height: int = 8
@export var piece_size = Vector2i(16, 16)
@export var board_pieces: Array = []

@export var possible_piences: Array[PackedScene]
@export var destroy_match_timer: Timer
@export var slide_down_timer: Timer
@export var refill_timer: Timer

var selected_piece: Piece = null

func _ready():
	randomize()
	destroy_match_timer.timeout.connect(_on_destroy_match_timer_timeout)
	slide_down_timer.timeout.connect(_on_slide_down_timer_timeout)
	refill_timer.timeout.connect(_on_refill_timer_timeout)
	_initialize_board_array()	
	_initialize_board()


func _grid_to_pixel(board_position: Vector2i) -> Vector2:
	return Vector2(board_position * piece_size)


func _pixe_to_grid(pixel_position: Vector2) -> Vector2i:
	return Vector2i(pixel_position) / piece_size


func _initialize_board_array() -> void:
	for row in range(width):
		var vec = []
		for column in range(height):
			vec.append(null)
		board_pieces.append(vec)


func _initialize_board() -> void:
	for row in range(width):
		for column in range(height):
			var board_position = Vector2i(row, column)
			var new_piece = _create_piece()
			var loop = 0
			while _check_match(row, column, new_piece.piece_type) and loop < 100:
				print("piece", new_piece)
				print("piece type: ", new_piece.piece_type)
				print("loop: ", loop)
				new_piece.queue_free()
				new_piece = _create_piece()
				loop += 1
			board_pieces[board_position.x][board_position.y] = new_piece
			new_piece.move(board_position * piece_size)


func _move_piece(from: Vector2i, to: Vector2i) -> void:
	var from_piece: Piece = board_pieces[from.x][from.y]
	var to_piece: Piece = board_pieces[to.x][to.y]
	
	if (to_piece == null):
		return
		
	if (from_piece == null):
		return
	
	board_pieces[to.x][to.y] = from_piece
	board_pieces[from.x][from.y] = to_piece
	
	from_piece.move(_grid_to_pixel(to))
	to_piece.move(_grid_to_pixel(from))
	
	_find_and_set_matchs()


func _create_piece() -> Piece:
	var piece: Piece = possible_piences[randi() % possible_piences.size()].instantiate()
	add_child(piece)
	piece.piece_selected.connect(_on_piece_piece_selected)
	return piece


func _slide_pieces_down() -> void:
	for row in range(width):
		for column in range(height - 1, -1, -1):
			if board_pieces[row][column] == null:
				for column_offset in range(column - 1, -1, -1):
					if board_pieces[row][column_offset] != null:
						board_pieces[row][column_offset].move(_grid_to_pixel(Vector2i(row, column)))
						board_pieces[row][column] = board_pieces[row][column_offset]
						board_pieces[row][column_offset] = null
						break


func _on_piece_piece_selected(piece: Piece):
	if selected_piece == null:
		selected_piece = piece
		selected_piece.selected = true
		return

	if selected_piece == piece:
		selected_piece.selected = false
		selected_piece = null
		return
	
	var selected_piece_board_position = _pixe_to_grid(selected_piece.position)
	var piece_board_position =_pixe_to_grid(piece.position)

	if (selected_piece_board_position - piece_board_position).length() > 1:
		selected_piece.selected = false
		selected_piece = piece
		selected_piece.selected = true
		return

	_swap_pieces(selected_piece_board_position, piece_board_position)
	selected_piece.selected = false
	piece.selected = false
	selected_piece = null

func _swap_pieces(from: Vector2i, to: Vector2i) -> void:
	_move_piece(from, to)

func _check_match(row: int, column: int, piece_type: String) -> bool:
	if row > 1:
		if (
			board_pieces[row - 1][column] != null
			and board_pieces[row - 2][column] != null
			and board_pieces[row - 1][column].piece_type == piece_type
			and board_pieces[row - 2][column].piece_type == piece_type):
			return true


	if column > 1:
		if (
			board_pieces[row][column - 1] != null
			and board_pieces[row][column - 2] != null
			and board_pieces[row][column - 1].piece_type == piece_type
			and board_pieces[row][column - 2].piece_type == piece_type):
			return true

	return false


func _destroy_matched() -> void:
	for row in range(width):
		for column in range(height):
			if board_pieces[row][column] == null:
				continue
			if not board_pieces[row][column].matched:
				continue
				
			board_pieces[row][column].destroy_matched()
			board_pieces[row][column] = null


func _on_destroy_match_timer_timeout():
	_destroy_matched()
	slide_down_timer.start()


func _find_and_set_matchs() -> void:
	var match_found = false
	for row in range(width):
		for column in range(height):
			if board_pieces[row][column] == null:
				continue

			var piece = board_pieces[row][column]
			var piece_type = piece.piece_type

			if row > 1:
				if (
					board_pieces[row - 1][column] != null
					and board_pieces[row - 2][column] != null
					and board_pieces[row - 1][column].piece_type == piece_type
					and board_pieces[row - 2][column].piece_type == piece_type):
					board_pieces[row - 1][column].matched = true
					board_pieces[row - 2][column].matched = true
					piece.matched = true

			if column > 1:
				if (
					board_pieces[row][column - 1] != null
					and board_pieces[row][column - 2] != null
					and board_pieces[row][column - 1].piece_type == piece_type
					and board_pieces[row][column - 2].piece_type == piece_type):
					board_pieces[row][column - 1].matched = true
					board_pieces[row][column - 2].matched = true
					piece.matched = true

			if piece.matched:
				match_found = true	
			
	if match_found:
		destroy_match_timer.start()


func _on_slide_down_timer_timeout() -> void:
	_slide_pieces_down()
	refill_timer.start()


func _refill_pieces() -> void:
	for row in width:
		for column in height:
			if board_pieces[row][column] == null:
				var new_piece = _create_piece()
				var spawn_board_position =  Vector2i(row, -1)
				var target_board_position = Vector2i(row, column)
				new_piece.position = _grid_to_pixel(spawn_board_position)
				new_piece.move(_grid_to_pixel(target_board_position))
				board_pieces[row][column] = new_piece


func _on_refill_timer_timeout() -> void:
	_refill_pieces()
	_find_and_set_matchs()
