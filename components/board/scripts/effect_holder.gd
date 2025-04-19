class_name EffectHolder extends Holder

func set_in_position(node: Effect, cell_position: Vector2i) -> void:
	super(node, cell_position)
	if node.destroyed.has_connections():
		return
	node.destroyed.connect(_on_effect_destroyed)

func get_in_position(cell_position: Vector2i) -> Effect:
	return super(cell_position)

func _on_effect_destroyed(effect: Effect) -> void:
	holding.erase(effect)
	
