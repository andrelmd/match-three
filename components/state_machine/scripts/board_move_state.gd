class_name BoardMoveState extends State

@export var board: Board
@export var has_moved_next_state: State

var selected_piece: Piece
var piece_buffer: Piece

func _ready() -> void:
	board.piece_created.connect(_on_board_piece_created)

func _on_board_piece_created(piece: Piece) -> void:
	piece.piece_selected.connect(_on_board_piece_selected)

func _on_board_piece_selected(piece: Piece) -> void:
	piece_buffer = piece

func update(_delta: float) -> void:
	if not piece_buffer:
		return
	
	handle_select_piece(piece_buffer)
	piece_buffer = null
	finished.emit(has_moved_next_state.name)

func handle_select_piece(piece: Piece):
	if selected_piece == null:
		selected_piece = piece
		selected_piece.is_selected = true
		return

	if selected_piece == piece:
		selected_piece.is_selected = false
		selected_piece = null
		return
	
	var selected_piece_board_position = board._pixel_to_grid(selected_piece.position)
	var piece_board_position = board._pixel_to_grid(piece.position)

	if (selected_piece_board_position - piece_board_position).length() > 1:
		selected_piece.is_selected = false
		selected_piece = piece
		selected_piece.is_selected = true
		return

	board._swap_pieces(selected_piece_board_position, piece_board_position)
	selected_piece.is_selected = false
	piece.is_selected = false
	selected_piece = null

func enter() -> void:
	piece_buffer = null
