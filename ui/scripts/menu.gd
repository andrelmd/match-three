extends Control

@export var back_button: Button
@export var exit_button: Button
@export var main_menu_button: Button

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _on_back_button_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_main_menu_button_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels/nodes/main_menu.tscn")
