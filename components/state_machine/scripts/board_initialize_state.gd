class_name BoardInitializeState extends State

@export var piece_holder: PieceHolder
@export var effect_holder: EffectHolder
@export var board: Board
@export var board_initialized_next_state: State
@export var effect_strategy_holder: Node

func enter() -> void:
	_initialize_piece_holder()
	_initialize_effect_holder()
	finished.emit(board_initialized_next_state.name)

func _initialize_piece_holder() -> void:
	piece_holder.initialize(board.max_width, board.max_height, board.cell_size)
	for width in board.max_width:
		for height in board.max_height:
			var cell_coordinate = Vector2i(width, height)
			if board._is_position_restricted_fill(cell_coordinate):
				continue
				
			var piece_type = board._get_random_piece_type()
			if board._check_match(cell_coordinate, piece_type):
				for loop in range(100):
					piece_type = board._get_random_piece_type()
					if not board._check_match(cell_coordinate, piece_type):
						break
			
			var new_piece = board._create_piece(board.piece_types.find(piece_type), cell_coordinate)
			new_piece.position = board.grid_to_pixel(cell_coordinate)

func _initialize_effect_holder() -> void:
	effect_holder.initialize(board.max_width, board.max_height, board.cell_size)
	for child: EffectStrategy in effect_strategy_holder.find_children("*", "EffectStrategy"):
		child.execute(board)
