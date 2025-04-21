class_name Board extends Node2D

@export_category("Board Configuration")
@export var max_width: int = 10
@export var max_height: int = 8
@export var x_start: int
@export var y_start: int
@export var cell_size = Vector2(16, 16)

@export_category("Holders")
@export var piece_holder: PieceHolder
@export var effect_holder: EffectHolder

@export_category("Special Fills")
@export var empty_spaces: Array[Vector2i]
@export var ice_spaces: Array[Vector2i]

@export_category("Pieces")
@export var possible_pieces: Array[PackedScene]

var piece_types: Array[String] = []

var first_piece_movement: Piece
var second_piece_movement: Piece

signal board_initialized
signal piece_created
signal board_refilled
signal piece_destroyed(amount: int)
signal move_made

func _ready():
	randomize()
	
	for piece in possible_pieces:
		var instance: Piece = piece.instantiate()
		piece_types.append(instance.piece_type)
		instance.queue_free()


func _get_random_piece_type() -> String:
	return piece_types.pick_random()

func _create_piece(index: int, cell_coordinate: Vector2i) -> Piece:
	var piece: Piece = possible_pieces[index].instantiate()
	piece_holder.add_child(piece)
	piece_holder.set_in_coordinate(piece, cell_coordinate)
	piece.position = grid_to_pixel(Vector2i(cell_coordinate.x, -1))
	piece_created.emit(piece)
	return piece

func has_horizontal_match(cell_coordinate: Vector2i, piece_type: String) -> bool:
	return get_quantity_horizontal_match(cell_coordinate, piece_type) >= 3

func has_vertical_match(cell_coordinate: Vector2i, piece_type: String) -> bool:
	return get_quantity_vertical_match(cell_coordinate, piece_type) >= 3

func get_quantity_horizontal_match(cell_coordinate: Vector2i, piece_type: String) -> int:
	var quantity: int = 0
	if cell_coordinate.x < 2:
		return quantity
	
	quantity += 1
	for width in range(cell_coordinate.x - 1, -1, -1):
		var cell_to_verify = Vector2i(width, cell_coordinate.y)
		
		if piece_holder.is_coordinate_null(cell_to_verify):
			break
		
		var piece = piece_holder.get_in_coordinate(cell_to_verify)
		
		if piece.piece_type != piece_type:
			break
		
		quantity += 1
	
	return quantity


func get_quantity_vertical_match(cell_coordinate: Vector2i, piece_type: String) -> int:
	var quantity: int = 0
	if cell_coordinate.y < 2:
		return quantity
	
	quantity += 1
	for height in range(cell_coordinate.y - 1, -1, -1):
		var cell_to_verify = Vector2i(cell_coordinate.x, height)
		
		if piece_holder.is_coordinate_null(cell_to_verify):
			break
		
		var piece = piece_holder.get_in_coordinate(cell_to_verify)
		
		if piece.piece_type != piece_type:
			break
		
		quantity += 1
	
	return quantity 

func _check_match(cell_coordinate: Vector2i, piece_type: String) -> bool:
	return has_horizontal_match(cell_coordinate, piece_type) or has_vertical_match(cell_coordinate, piece_type)

func find_matches() -> Array[Piece]:
	var matches: Array[Piece] = []
	for row in max_width:
		for column in max_height:
			var cell_coordinate = Vector2i(row, column)
			if piece_holder.is_coordinate_null(cell_coordinate):
				continue
				
			var piece = piece_holder.get_in_coordinate(cell_coordinate)
			var piece_type = piece.piece_type
			
			if row > 1:
				if has_horizontal_match(cell_coordinate, piece_type):
					for i in 3:
						var matching_piece = piece_holder.get_in_coordinate(Vector2i(row - i, column))
						if not matches.has(matching_piece):
							matches.append(matching_piece)
				
			if column > 1:
				if has_vertical_match(cell_coordinate, piece_type):
					for i in 3:
						var matching_piece = piece_holder.get_in_coordinate(Vector2i(row, column - i))
						if not matches.has(matching_piece):
							matches.append(matching_piece)
	return matches

func _is_position_restricted_fill(cell_coordinate: Vector2i):
	return _is_position_in_array(empty_spaces, cell_coordinate)

func _is_position_in_array(array: Array, cell_coordinate: Vector2i) -> bool:
	for i in array.size():
		if array[i] == cell_coordinate:
			return true
	return false

func grid_to_pixel(cell_position: Vector2i) -> Vector2:
	return Vector2(x_start + cell_size.x * cell_position.x, y_start + cell_size.y * cell_position.y)

func pixel_to_grid(global_pixel_position: Vector2) -> Vector2i:
	var new_x = roundi((global_pixel_position.x - x_start) / cell_size.x)
	var new_y = roundi((global_pixel_position.y - y_start) / cell_size.y)
	return Vector2i(new_x, new_y)

func is_inside_board(cell_coordinate: Vector2i) -> bool:
	return cell_coordinate.x >= 0 and cell_coordinate.x < max_width and cell_coordinate.y >= 0 and cell_coordinate.y < max_height
