class_name Board extends Node2D

@export_category("Board Configuration")
@export var max_width: int = 10
@export var max_height: int = 8
@export var x_start: int
@export var y_start: int
@export var offset: int
@export var piece_size = Vector2(16, 16)

@export_category("Holders")
@export var piece_holder: PieceHolder
@export var effect_holder: EffectHolder

@export_category("Special Fills")
@export var empty_spaces: Array[Vector2i]
@export var ice_spaces: Array[Vector2i]

@export_category("Pieces")
@export var possible_pieces: Array[PackedScene]
@export var ice_effect: PackedScene

var piece_types: Array[String] = []

signal board_initialized
signal piece_created
signal board_refilled
signal points_received(amount: int)
signal move_made

func _ready():
	randomize()
	
	for piece in possible_pieces:
		var instance: Piece = piece.instantiate()
		piece_types.append(instance.piece_type)
		instance.queue_free()

func _initialize_piece_holder() -> void:
	piece_holder.initialize(max_width, max_height, piece_size)
	for width in max_width:
		for height in max_height:
			var cell_coordinate = Vector2i(width, height)
			if _is_position_restricted_fill(cell_coordinate):
				continue
				
			var piece_type = _get_random_piece_type()
			if _check_match(cell_coordinate, piece_type):
				for loop in range(100):
					piece_type = _get_random_piece_type()
					if not _check_match(cell_coordinate, piece_type):
						break
			
			var new_piece = _create_piece(piece_types.find(piece_type), cell_coordinate)
			new_piece.position = grid_to_pixel(cell_coordinate)

func _initialize_effect_holder() -> void:
	effect_holder.initialize(max_width, max_height, piece_size)
	spawn_ice()

func initialize() -> void:
	_initialize_piece_holder()
	_initialize_effect_holder()
	board_initialized.emit()


func _move_piece(from_coordinate: Vector2i, to_coordinate: Vector2i) -> void:
	var from_piece: Piece = piece_holder.get_in_position(from_coordinate)
	var to_piece: Piece = piece_holder.get_in_position(to_coordinate)
	
	if (to_piece == null or from_piece == null):
		return
	
	piece_holder.set_in_position(from_piece, to_coordinate)
	piece_holder.set_in_position(to_piece, from_coordinate)
	
	from_piece.move(grid_to_pixel(to_coordinate))
	to_piece.move(grid_to_pixel(from_coordinate))

func _get_random_piece_type() -> String:
	return piece_types.pick_random()

func _create_piece(index: int, cell_coordinate: Vector2i) -> Piece:
	var piece: Piece = possible_pieces[index].instantiate()
	piece_holder.add_child(piece)
	piece_holder.set_in_position(piece, cell_coordinate)
	piece.position = grid_to_pixel(Vector2i(cell_coordinate.x, -1))
	piece_created.emit(piece)
	return piece

func _slide_pieces_down() -> void:
	for width in range(max_width):
		for height in range(max_height - 1, -1, -1):
			var cell_fill_coordinate = Vector2i(width, height)
			if not piece_holder.is_position_null(cell_fill_coordinate):
				continue
				
			if _is_position_restricted_fill(cell_fill_coordinate):
				continue
				
			for height_offset in range(height - 1, -1, -1):
				var piece_cell_coordinate = Vector2i(width, height_offset)
				if piece_holder.is_position_null(piece_cell_coordinate):
					continue
				
				if _is_position_restricted_fill(piece_cell_coordinate):
					continue
				
				var piece = piece_holder.get_in_position(piece_cell_coordinate)
				piece.move(grid_to_pixel(cell_fill_coordinate))
				piece_holder.set_in_position(piece, cell_fill_coordinate)
				piece_holder.set_null_in_position(piece_cell_coordinate)
				break

func _swap_pieces(from: Vector2i, to: Vector2i) -> void:
	_move_piece(from, to)
	move_made.emit()


func _check_horizontal_match(cell_coordinate: Vector2i, piece_type: String) -> bool:
	if cell_coordinate.x < 2:
		return false

	var left_piece = piece_holder.get_in_position(Vector2i(cell_coordinate.x - 1, cell_coordinate.y))
	var left_most_piece = piece_holder.get_in_position(Vector2i(cell_coordinate.x - 2, cell_coordinate.y))
	
	if left_piece == null or left_most_piece == null:
		return false
	
	if (left_piece.piece_type != piece_type or
		 left_most_piece.piece_type != piece_type):
			return false
	
	return true

func _check_vertical_match(cell_coordinate: Vector2i, piece_type: String) -> bool:
	if cell_coordinate.y < 2:
		return false

	var upper_piece = piece_holder.get_in_position(Vector2i(cell_coordinate.x, cell_coordinate.y - 1))
	var upper_most_piece = piece_holder.get_in_position(Vector2i(cell_coordinate.x, cell_coordinate.y - 2))
	
	if upper_piece == null or upper_most_piece == null:
		return false
	
	if (upper_piece.piece_type != piece_type or
		 upper_most_piece.piece_type != piece_type):
			return false
	
	return true

func _check_match(cell_coordinate: Vector2i, piece_type: String) -> bool:
	return _check_horizontal_match(cell_coordinate, piece_type) or _check_vertical_match(cell_coordinate, piece_type)

func _destroy_matched() -> bool:
	var has_destroyed: bool = false
	var quantity_destroyed = 0
	for row in max_width:
		for column in max_height:
			var board_position = Vector2i(row, column)
			if piece_holder.is_position_null(board_position):
				continue
			if not piece_holder.get_in_position(board_position).matched:
				continue
			
			piece_holder.get_in_position(board_position).destroy_matched()
			piece_holder.set_in_position(null, board_position)
			_destroy_ices(board_position)
			quantity_destroyed = quantity_destroyed + 1
			has_destroyed = true
	
	points_received.emit(_calculate_points_received(quantity_destroyed))
	return has_destroyed

func _find_and_set_matchs() -> bool:
	var match_found = false
	for row in max_width:
		for column in max_height:
			var cell_coordinate = Vector2i(row, column)
			if piece_holder.is_position_null(cell_coordinate):
				continue
				
			var piece = piece_holder.get_in_position(cell_coordinate)
			var piece_type = piece.piece_type
			
			if row > 1:
				if _check_horizontal_match(cell_coordinate, piece_type):
					piece_holder.get_in_position(Vector2i(row - 1, column)).matched = true
					piece_holder.get_in_position(Vector2i(row - 2, column)).matched = true
					piece.matched = true
				
			if column > 1:
				if (_check_vertical_match(cell_coordinate, piece_type)):
					piece_holder.get_in_position(Vector2i(row, column - 1)).matched = true
					piece_holder.get_in_position(Vector2i(row, column - 2)).matched = true
					piece.matched = true
			
			if piece.matched:
				match_found = true
			
	return match_found

func _refill_pieces() -> void:
	for width in max_width:
		for height in max_height:
			var cell_coordinate = Vector2i(width, height)
			if not piece_holder.is_position_null(cell_coordinate):
				continue
			if _is_position_restricted_fill(cell_coordinate):
				continue
			var new_piece = _create_piece(randi() % possible_pieces.size(), cell_coordinate)
			new_piece.move(grid_to_pixel(cell_coordinate))

func _is_position_restricted_fill(cell_coordinate: Vector2i):
	return _is_position_in_array(empty_spaces, cell_coordinate)

func _is_position_in_array(array: Array, cell_coordinate: Vector2i) -> bool:
	for i in array.size():
		if array[i] == cell_coordinate:
			return true
	return false

func spawn_ice():
	for width in max_width:
		for height in max_height:
			var cell_coordinate = Vector2i(width, height)
			if _is_position_in_array(ice_spaces, cell_coordinate):
				var new_ice = ice_effect.instantiate()
				effect_holder.add_child(new_ice)
				effect_holder.set_in_position(new_ice, cell_coordinate)
				new_ice.position = grid_to_pixel(cell_coordinate)

func _destroy_ices(target_position: Vector2i) -> void:
	for effect in effect_holder.holding:
		if effect  == null or not effect is IceEffect:
			continue
		
		if (pixel_to_grid(effect.position) - target_position).length()  > 1:
			continue
	
		effect.take_damage(1)

func _calculate_points_received(quantity_destroyed: int):
	var surplus = quantity_destroyed % 3

	if surplus == 0:
		@warning_ignore("integer_division")
		return quantity_destroyed / 3
	elif surplus == 1:
		@warning_ignore("integer_division")
		return (quantity_destroyed - 1) / 3 + 1
	else:
		@warning_ignore("integer_division")
		return (quantity_destroyed - 2) / 3 + 2

func grid_to_pixel(cell_position: Vector2i) -> Vector2:
	return Vector2(x_start + offset * cell_position.x, y_start + offset * cell_position.y)

func pixel_to_grid(global_pixel_position: Vector2) -> Vector2i:
	var new_x = roundi((global_pixel_position.x - x_start) / offset)
	var new_y = roundi((global_pixel_position.y - y_start) / offset)
	return Vector2i(new_x, new_y)
