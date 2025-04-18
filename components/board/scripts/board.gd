class_name Board extends Node2D

@export_category("Board Configuration")
@export var max_width: int = 10
@export var max_height: int = 8
@export var piece_size = Vector2i(16, 16)
@export var pieces: Array[Piece] = []
@export var ices: Array[IceEffect] = []

@export_category("Holders")
@export var piece_holder: PieceHolder
@export var ice_holder: Node2D

@export_category("Special Fills")
@export var empty_spaces: Array[Vector2i]
@export var ice_spaces: Array[Vector2i]

@export_category("Pieces")
@export var possible_pieces: Array[PackedScene]
@export var ice_piece: PackedScene

@export_category("Timers")
@export var destroy_match_timer: Timer
@export var slide_down_timer: Timer
@export var refill_timer: Timer

var piece_types: Array[String] = []

var selected_piece: Piece = null

signal board_initialized
signal piece_created
signal board_refilled

func _ready():
	randomize()
	
	for piece in possible_pieces:
		var instance: Piece = piece.instantiate()
		piece_types.append(instance.piece_type)
		instance.queue_free()


func _is_position_valid(target_position: Vector2i) -> bool:
	if not pieces.size() > _get_array_position(target_position):
		return false
	if _get_array_position(target_position) < 0:
		return false
	
	return true


func _get_array_position(target_position: Vector2i):
	return target_position.x * max_height + target_position.y


func get_piece_in_position(target_position: Vector2i) -> Piece:
	if _is_position_valid(target_position):
		return pieces[_get_array_position(target_position)]
	
	return null


func set_piece_in_position(piece: Piece, target_position: Vector2i):
	if _is_position_valid(target_position):
		pieces[_get_array_position(target_position)] = piece

func set_effect_in_position(effect: IceEffect, target_position: Vector2i):
	if _is_position_valid(target_position):
		ices[_get_array_position(target_position)] = effect

func set_null_in_position(target_position: Vector2i) -> void:
	pieces[_get_array_position(target_position)] = null


func is_position_null(target_position: Vector2i) -> bool:
	if not _is_position_valid(target_position):
		return true

	return pieces[_get_array_position(target_position)] == null


func _grid_to_pixel(board_position: Vector2i) -> Vector2:
	return Vector2(board_position * piece_size)


func _pixel_to_grid(pixel_position: Vector2) -> Vector2i:
	return Vector2i(pixel_position) / piece_size


func _initialize_board() -> void:
	pieces.resize(max_width * max_height)
	for width in max_width:
		for height in max_height:
			var board_position = Vector2i(width, height)
			
			if _is_position_restricted_fill(board_position):
				continue

			var piece_type = _get_random_piece_type()
			if _check_match(width, height, piece_type):
				for loop in range(100):
					piece_type = _get_random_piece_type()
					if not _check_match(width, height, piece_type):
						break
			
			var new_piece = _create_piece(piece_types.find(piece_type), board_position)
			new_piece.move(_grid_to_pixel(board_position))
	board_initialized.emit()


func _move_piece(from: Vector2i, to: Vector2i) -> void:
	var from_piece: Piece = get_piece_in_position(from)
	var to_piece: Piece = get_piece_in_position(to)
	
	if (to_piece == null
		or from_piece == null):
		return
	
	set_piece_in_position(from_piece, to)
	set_piece_in_position(to_piece, from)
	
	from_piece.move(_grid_to_pixel(to))
	to_piece.move(_grid_to_pixel(from))

func _get_random_piece_type() -> String:
	return piece_types.pick_random()

func _create_piece(index: int, target_position: Vector2i) -> Piece:
	var piece: Piece = possible_pieces[index].instantiate()
	set_piece_in_position(piece, target_position)
	piece_holder.add_child(piece)
	piece.position = _grid_to_pixel(Vector2i(target_position.x, -1))
	piece_created.emit(piece)
	return piece


func _slide_pieces_down() -> void:
	for width in range(max_width):
		for height in range(max_height - 1, -1, -1):
			var position_to_fill = Vector2i(width, height)
			if not is_position_null(position_to_fill):
				continue
				
			if _is_position_restricted_fill(position_to_fill):
				continue
				
			for height_offset in range(height - 1, -1, -1):
				var position_to_get_piece = Vector2i(width, height_offset)
				if is_position_null(position_to_get_piece):
					continue
				
				if _is_position_restricted_fill(position_to_get_piece):
					continue
				
				var piece = get_piece_in_position(position_to_get_piece)
				
				piece.move(_grid_to_pixel(position_to_fill))
				set_piece_in_position(piece, position_to_fill)
				set_null_in_position(position_to_get_piece)
				break


func _swap_pieces(from: Vector2i, to: Vector2i) -> void:
	_move_piece(from, to)


func _check_horizontal_match(width: int, height: int, piece_type: String) -> bool:
	if width < 2:
		return false

	var left_piece = get_piece_in_position(Vector2i(width - 1, height))
	var left_most_piece = get_piece_in_position(Vector2i(width - 2, height))
	
	if left_piece == null or left_most_piece == null:
		return false
	
	if (left_piece.piece_type != piece_type or
		 left_most_piece.piece_type != piece_type):
			return false
	
	return true

func _check_vertical_match(width: int, height: int, piece_type: String) -> bool:
	if height < 2:
		return false

	var upper_piece = get_piece_in_position(Vector2i(width, height - 1))
	var upper_most_piece = get_piece_in_position(Vector2i(width, height - 2))
	
	if upper_piece == null or upper_most_piece == null:
		return false
	
	if (upper_piece.piece_type != piece_type or
		 upper_most_piece.piece_type != piece_type):
			return false
	
	return true


func _check_match(width: int, height: int, piece_type: String) -> bool:
	return _check_horizontal_match(width, height, piece_type) or _check_vertical_match(width, height, piece_type)


func _destroy_matched() -> bool:
	var has_destroyed: bool = false
	for row in max_width:
		for column in max_height:
			var board_position = Vector2i(row, column)
			if is_position_null(board_position):
				continue
			if not get_piece_in_position(board_position).matched:
				continue
			
			get_piece_in_position(board_position).destroy_matched()
			set_piece_in_position(null, board_position)
			_destroy_ices(board_position)
			has_destroyed = true
	
	return has_destroyed


func _find_and_set_matchs() -> bool:
	var match_found = false
	for row in max_width:
		for column in max_height:
			var board_position = Vector2i(row, column)
			if is_position_null(board_position):
				continue

			var piece = get_piece_in_position(board_position)
			var piece_type = piece.piece_type

			if row > 1:
				if _check_horizontal_match(row, column, piece_type):
					get_piece_in_position(Vector2i(row - 1, column)).matched = true
					get_piece_in_position(Vector2i(row - 2, column)).matched = true
					piece.matched = true

			if column > 1:
				if (_check_vertical_match(row, column, piece_type)):
					get_piece_in_position(Vector2i(row, column - 1)).matched = true
					get_piece_in_position(Vector2i(row, column - 2)).matched = true
					piece.matched = true
			
			if piece.matched:
				match_found = true
			
	return match_found

func _refill_pieces() -> void:
	for width in max_width:
		for height in max_height:
			var target_board_position = Vector2i(width, height)
			if not is_position_null(target_board_position):
				continue
			if _is_position_restricted_fill(target_board_position):
				continue
			var new_piece = _create_piece(randi() % possible_pieces.size(), target_board_position)
			new_piece.move(_grid_to_pixel(target_board_position))

func _is_position_restricted_fill(target_position: Vector2i):
	return _is_position_in_array(empty_spaces, target_position)

func _is_position_in_array(array: Array, target_position: Vector2i) -> bool:
	for i in array.size():
		if array[i] == target_position:
			return true
	return false

func spawn_ice():
	ices.resize(max_width * max_height)
	for width in max_width:
		for height in max_height:
			var cell_position = Vector2i(width, height)
			if _is_position_in_array(ice_spaces, cell_position):
				var new_ice_piece = ice_piece.instantiate()
				ice_holder.add_child(new_ice_piece)
				set_effect_in_position(new_ice_piece, cell_position)
				new_ice_piece.position = _grid_to_pixel(cell_position)

func _destroy_ices(target_position: Vector2i) -> void:
	for ice in ices:
		if not ice: continue
		var cell_position = _pixel_to_grid(ice.position)
		if (target_position - cell_position).length() > 1:
			continue
		
		ice.take_damage(1)
