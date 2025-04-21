class_name EffectStrategy extends Node

@export var effect_coordinates: Array[Vector2i]
@export var effect_scene: PackedScene

func execute(_board: Board) -> void:
	pass

func execute_damage(_board:Board, _cell_coordinates_to_destroy: Array[Vector2i]) -> void:
	pass
