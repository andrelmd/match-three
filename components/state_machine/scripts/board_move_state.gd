class_name BoardMoveState extends State

@export var board: Board
@export var has_moved_next_state: State

var movement_start_coordinate: Vector2i = Vector2i.ZERO
var movement_end_coordinate: Vector2i = Vector2i.ZERO
var has_moved: bool = false

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_touch"):
		movement_start_coordinate = board.pixel_to_grid(get_viewport().get_mouse_position())
	if event.is_action_released("ui_touch"):
		movement_end_coordinate = board.pixel_to_grid(get_viewport().get_mouse_position())
	
	if movement_end_coordinate != Vector2i.ZERO:
		handle_select_piece()
		movement_end_coordinate = Vector2i.ZERO
		has_moved = true

func enter() -> void:
	has_moved = false

func update(_delta: float) -> void:
	if has_moved:
		finished.emit(has_moved_next_state.name)

func handle_select_piece():
	var direction = Vector2i(Vector2(movement_end_coordinate - movement_start_coordinate).normalized())
	var first_piece_cell_coordinate = movement_start_coordinate
	var second_piece_cell_coordinate = movement_start_coordinate + direction
	var first_piece = board.piece_holder.get_in_position(first_piece_cell_coordinate)
	var second_piece = board.piece_holder.get_in_position(second_piece_cell_coordinate)
	
	if first_piece == null or second_piece == null:
		return

	first_piece.is_selected = true
	second_piece.is_selected = true

	board._swap_pieces(first_piece_cell_coordinate, second_piece_cell_coordinate)
	first_piece.is_selected = false
	second_piece.is_selected = false
