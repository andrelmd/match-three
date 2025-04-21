class_name BoardDestroyMatchState extends State

@export var board: Board
@export var piece_holder: PieceHolder
@export var effect_holder: EffectHolder
@export var effect_strategy_holder: Node
@export var destroy_match_timer: Timer
@export var has_destroyed_next_state: State

func enter() -> void:
	destroy_match_timer.start()
	await destroy_match_timer.timeout
	await _destroy_matched()
	finished.emit(has_destroyed_next_state.name)

func _destroy_matched() -> void:
	var cell_coordinates_to_destroy: Array[Vector2i] = []
	
	for row in board.max_width:
		for column in board.max_height:
			var cell_coordinate = Vector2i(row, column)
			if piece_holder.is_coordinate_null(cell_coordinate):
				continue
				
			if not piece_holder.get_in_coordinate(cell_coordinate).matched:
				continue
			
			cell_coordinates_to_destroy.append(cell_coordinate)
	
	for cell_coordinate in cell_coordinates_to_destroy:
		var piece = piece_holder.get_in_coordinate(cell_coordinate)
		piece_holder.set_in_coordinate(null, board.pixel_to_grid(piece.position))
		await piece.destroy_matched()
	
	_damage_specials(cell_coordinates_to_destroy)
	
	if cell_coordinates_to_destroy.size() > 0:
		board.piece_destroyed.emit(cell_coordinates_to_destroy.size())

func _damage_specials(cell_coordinates_to_destroy: Array[Vector2i]) -> void:
	for effect_strategy: EffectStrategy in effect_strategy_holder.find_children("*", "EffectStrategy"):
		await effect_strategy.execute_damage(board, cell_coordinates_to_destroy)
