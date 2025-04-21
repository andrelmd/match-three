class_name BlinkComponent extends Node

@export var sprite: Sprite2D

signal finished

func blink(duration_s: float) -> void:
	var tween = create_tween().tween_property(sprite, "modulate:v", 1, duration_s).from(15)
	await tween.finished
