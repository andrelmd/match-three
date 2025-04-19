extends Node2D

@export var menu: Control

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		menu.visible = true
		get_tree().paused = true
