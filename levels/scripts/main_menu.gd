class_name MainMenu extends Control

@export var exit_button: Button = null
@export var new_game_button: Button = null

func _ready() -> void:
	exit_button.pressed.connect(_on_exit_button_pressed)
	new_game_button.pressed.connect(_on_new_game_button_pressed)

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/nodes/world.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
