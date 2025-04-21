class_name EffectHolder extends Holder

var is_restricting_fill: bool = false

func set_in_coordinate(node: Effect, cell_coordinate: Vector2i) -> void:
	super(node, cell_coordinate)
	if node.destroyed.has_connections():
		return
	node.destroyed.connect(_on_effect_destroyed)

func get_in_coordinate(cell_coordinate: Vector2i) -> Effect:
	return super(cell_coordinate)

func _on_effect_destroyed(effect: Effect) -> void:
	holding.erase(effect)

func is_coordinate_restricted_fill(cell_coordinate: Vector2i) -> bool:
	var is_null = is_coordinate_null(cell_coordinate)
	if is_null:
		return false
	
	return is_restricting_fill
