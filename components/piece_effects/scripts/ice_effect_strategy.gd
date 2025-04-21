class_name IceEffectStrategy extends EffectStrategy

func execute(board: Board) -> void:
	var effect_holder = board.effect_holder
	for width in board.max_width:
		for height in board.max_height:
			var cell_coordinate = Vector2i(width, height)
			if board._is_position_in_array(effect_coordinates, cell_coordinate):
				var new_ice = effect_scene.instantiate()
				effect_holder.add_child(new_ice)
				effect_holder.set_in_coordinate(new_ice, cell_coordinate)
				new_ice.position = board.grid_to_pixel(cell_coordinate)

func execute_damage(board: Board, cell_coordinates_to_destroy: Array[Vector2i]) -> void:
	var effect_holder : EffectHolder = board.effect_holder
	for effect: IceEffect in effect_holder.holding.filter(func (x): return x is IceEffect):
		var vectors = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].map(func (vector): return vector + board.pixel_to_grid(effect.position))
		for cell_coordinate in cell_coordinates_to_destroy:
			if vectors.has(cell_coordinate):
				await effect.take_damage(1)
