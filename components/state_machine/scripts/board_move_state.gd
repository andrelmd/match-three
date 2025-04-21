class_name BoardMoveState extends State

@export var board: Board
@export var piece_holder: PieceHolder
@export var has_moved_next_state: State

var movement_start_coordinate: Vector2i = Vector2i.ZERO
var movement_end_coordinate: Vector2i = Vector2i.ZERO

func handle_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_touch") and not event.is_action_released("ui_touch"):
		return
	
	if event.is_action_pressed("ui_touch"):
		movement_start_coordinate = board.pixel_to_grid(get_viewport().get_mouse_position())
	if event.is_action_released("ui_touch"):
		movement_end_coordinate = board.pixel_to_grid(get_viewport().get_mouse_position())
	
	if (movement_end_coordinate != Vector2i.ZERO 
		and board.is_inside_board(movement_start_coordinate)
		and board.is_inside_board(movement_end_coordinate)
		):
		await handle_piece_move()
		movement_end_coordinate = Vector2i.ZERO
		movement_start_coordinate = Vector2i.ZERO
		finished.emit(has_moved_next_state.name)

func handle_piece_move():
	var direction = Vector2i(Vector2(movement_end_coordinate - movement_start_coordinate).normalized())
	var first_piece_cell_coordinate = movement_start_coordinate
	var second_piece_cell_coordinate = movement_start_coordinate + direction
	var first_piece = piece_holder.get_in_coordinate(first_piece_cell_coordinate)
	var second_piece = piece_holder.get_in_coordinate(second_piece_cell_coordinate)
	
	if first_piece == null or second_piece == null:
		return

	first_piece.is_selected = true
	second_piece.is_selected = true
	
	board.first_piece_movement = first_piece
	board.second_piece_movement = second_piece

	await _swap_pieces(first_piece_cell_coordinate, second_piece_cell_coordinate)
	first_piece.is_selected = false
	second_piece.is_selected = false

func _move_piece(from_coordinate: Vector2i, to_coordinate: Vector2i) -> void:
	var from_piece: Piece = piece_holder.get_in_coordinate(from_coordinate)
	var to_piece: Piece = piece_holder.get_in_coordinate(to_coordinate)
	
	if (to_piece == null or from_piece == null):
		return
	
	piece_holder.set_in_coordinate(from_piece, to_coordinate)
	piece_holder.set_in_coordinate(to_piece, from_coordinate)
	
	from_piece.move(board.grid_to_pixel(to_coordinate))
	to_piece.move(board.grid_to_pixel(from_coordinate))
	
	await from_piece.has_moved
	await to_piece.has_moved

func _swap_pieces(from: Vector2i, to: Vector2i) -> void:
	await _move_piece(from, to)
	board.move_made.emit()
