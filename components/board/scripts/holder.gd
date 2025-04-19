class_name Holder extends Node2D

var holding: Array[Node2D] = []
var max_width: int
var max_height: int
var cell_size: Vector2 = Vector2(0, 0)

func initialize(width: int, height: int, new_cell_size: Vector2) -> void:
	max_width = width
	max_height = height
	cell_size = new_cell_size
	holding.resize(max_height * max_width)

func _is_position_valid(cell_position: Vector2i) -> bool:
	if not holding.size() > _get_array_position(cell_position):
		return false
	if _get_array_position(cell_position) < 0:
		return false
	
	return true

func _get_array_position(cell_position: Vector2i):
	return cell_position.x * max_height + cell_position.y

func get_in_position(cell_position: Vector2i) -> Variant:
	if _is_position_valid(cell_position):
		return holding[_get_array_position(cell_position)]
	
	return null

func set_in_position(node, cell_position: Vector2i) -> void:
	if _is_position_valid(cell_position):
		holding[_get_array_position(cell_position)] = node

func set_null_in_position(cell_position: Vector2i) -> void:
	holding[_get_array_position(cell_position)] = null

func is_position_null(cell_position: Vector2i) -> bool:
	if not _is_position_valid(cell_position):
		return true

	return holding[_get_array_position(cell_position)] == null
