extends TileMapLayer

@export var board_size = Vector2i(8, 8)
@export var possible_piences: Array[PackedScene]

var pieces_on_board: Array = []
var selected_piece: Piece
var tween: Tween
var can_move: bool = true

func generate_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i]

	for x in range(board_size.x):
		for y in range(board_size.y):
			cells.append(Vector2i(x, y))

	return cells

func generate_2d_array():
	var array = []

	for x in range(board_size.x - 2):
		array.append([])
		for y in range(board_size.y - 2):
			array[x].append(null)

	return array

func randomize_piece() -> PackedScene:
	var piece = possible_piences[randi() % possible_piences.size()]
	return piece

func create_piece(cell: Vector2i):
	var piece: Piece = randomize_piece().instantiate()
	var array_position = _board_to_array_position(cell)
	var piece_name = piece.piece_name
	print("Creating piece: ", piece_name, " at: ", array_position)
	print("Checking for matches")
	while (_match_3_at(cell, piece_name)):
		print("Match 3 found, re-rolling piece")
		piece.queue_free()
		piece = randomize_piece().instantiate()
		piece_name = piece.piece_name
	
	# var new_label: Label = Label.new()
	# new_label.scale = Vector2(0.4, 0.4)
	# new_label.modulate = Color(0, 0, 0)
	# new_label.text = "(" + str(array_position.x) + ", " + str(array_position.y) + ")"
	# new_label.position = Vector2(-8, -8)
	# piece.add_child(new_label)
	add_child(piece)
	piece.piece_selected.connect(_on_piece_selected)
	piece.piece_deselected.connect(_on_piece_deselected)
	piece.position = map_to_local(cell)
	pieces_on_board[array_position.x][array_position.y] = piece

func remove_piece(cell: Vector2i):
	var array_position = _board_to_array_position(cell)
	var piece = pieces_on_board[array_position.x][array_position.y]
	piece.queue_free()
	pieces_on_board[array_position.x][array_position.y] = null

func _get_piece_at(cell: Vector2i) -> Piece:
	var array_position = _board_to_array_position(cell)
	return pieces_on_board[array_position.x][array_position.y]

func _match_3_row(cell: Vector2i, piece_name: String) -> bool:
	var array_position = _board_to_array_position(cell)

	var matches = 1

	var x_start = array_position.x
	var y_start = array_position.y

	for x in range(x_start + 1, pieces_on_board.size()):
		if pieces_on_board[x][y_start] == null:
			break

		if pieces_on_board[x][y_start].piece_name == piece_name:
			matches += 1
		else:
			break

	for x in range(x_start - 1, 0, -1):
		if pieces_on_board[x][y_start] == null:
			break

		if pieces_on_board[x][y_start].piece_name == piece_name:
			matches += 1
		else:
			break

	if matches >= 3:
		return true

	return false

func _match_3_column(cell: Vector2i, piece_name: String) -> bool:
	var array_position = _board_to_array_position(cell)

	var matches = 1
	
	var x_start = array_position.x
	var y_start = array_position.y

	for y in range(y_start + 1, pieces_on_board[x_start].size()):
		if pieces_on_board[x_start][y] == null:
			break

		if pieces_on_board[x_start][y].piece_name == piece_name:
			matches += 1
		else:
			break

	for y in range(y_start - 1, 0, -1):
		if pieces_on_board[x_start][y] == null:
			break
		if pieces_on_board[x_start][y].piece_name == piece_name:
			matches += 1
		else:
			break

	if matches >= 3:
		return true

	return false


func _match_3_at(cell: Vector2i, piece_name: String) -> bool:
	return _match_3_row(cell, piece_name) or _match_3_column(cell, piece_name)

func _board_to_array_position(cell: Vector2i) -> Vector2i:
	return cell - Vector2i(1, 1)

func array_to_board_position(cell: Vector2i) -> Vector2i:
	return cell + Vector2i(1, 1)


func spawn_pieces():
	for x in range(1, board_size.x - 1):
		for y in range(1, board_size.y - 1):
			var cell_location = Vector2i(x, y)
			create_piece(cell_location)

func _find_piece_on_array(piece: Piece) -> Vector2i:
	for x in range(board_size.x - 2):
		for y in range(board_size.y - 2):
			if pieces_on_board[x][y] == piece:
				return Vector2i(x, y)

	return Vector2i(-1, -1)

func _on_piece_selected(piece: Piece):
	if selected_piece == null:
		selected_piece = piece
		return

	if can_move == false:
		selected_piece.selected = false
		piece.selected = false
		selected_piece = null
		return

	var selected_piece_position = _find_piece_on_array(selected_piece)
	var piece_position = _find_piece_on_array(piece)

	_swap_pieces(array_to_board_position(selected_piece_position), array_to_board_position(piece_position))

	selected_piece.selected = false
	piece.selected = false
	selected_piece = null

func _on_piece_deselected(_piece: Piece):
	selected_piece = null

	
func _swap_pieces(cell_1: Vector2i, cell_2: Vector2i, already_swapped: bool = false):
	can_move = false

	var array_position_1 = _board_to_array_position(cell_1)
	var array_position_2 = _board_to_array_position(cell_2)

	var piece_1: Piece = pieces_on_board[array_position_1.x][array_position_1.y]
	var piece_2: Piece = pieces_on_board[array_position_2.x][array_position_2.y]

	pieces_on_board[array_position_1.x][array_position_1.y] = piece_2
	pieces_on_board[array_position_2.x][array_position_2.y] = piece_1

	if tween != null:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(piece_1, "position", map_to_local(cell_2), 0.1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(piece_2, "position", map_to_local(cell_1), 0.1).set_ease(Tween.EASE_IN_OUT)
	# tween.tween_property(piece_1.get_child(1), "text", "(" + str(array_position_2.x) + ", " + str(array_position_2.y) + ")", 0.1).set_ease(Tween.EASE_IN_OUT)
	# tween.tween_property(piece_2.get_child(1), "text", "(" + str(array_position_1.x) + ", " + str(array_position_1.y) + ")", 0.1).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().play()
	if !already_swapped:
		tween.finished.connect(_on_tween_finished.bind(piece_1, piece_2))

func _on_tween_finished(piece_1: Piece, piece_2: Piece):

	var piece_1_position = _find_piece_on_array(piece_1)
	var piece_2_position = _find_piece_on_array(piece_2)
	if (!_match_3_at(array_to_board_position(piece_1_position), piece_1.piece_name) and !_match_3_at(array_to_board_position(piece_2_position), piece_2.piece_name)):
		_swap_pieces(array_to_board_position(piece_1_position), array_to_board_position(piece_2_position), true)
	
	can_move = true
	

func _ready():
	randomize()

	var cells: Array[Vector2i] = generate_cells()
	pieces_on_board = generate_2d_array()

	spawn_pieces()

	set_cells_terrain_connect(cells, 0, 0)
