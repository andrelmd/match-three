extends Control

@export var time_label: Label
@export var points_label: Label
@export var moves_made_label: Label
@export var board: Board
@export var elapsed_time_timer: Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	elapsed_time_timer.timeout.connect(_on_elapsed_time_timer)
	board.points_received.connect(_on_board_points_received)
	board.move_made.connect(_on_board_move_made)

func _on_elapsed_time_timer() -> void:
	var value = (int(time_label.text.substr(0, 2)) * 60 + int(time_label.text.substr(3, 2))) + 1
	@warning_ignore("integer_division")
	var minutes = value / 60
	var seconds = value % 60
	var minutes_str = str(minutes).lpad(2, "0")
	var seconds_str = str(seconds).lpad(2, "0")
	time_label.text = str(minutes_str + ":" + seconds_str)

func _on_board_points_received(amount: int):
	var value = int(points_label.text)
	points_label.text = str(value + amount).lpad(3, "0")

func _on_board_move_made():
	var value = int(moves_made_label.text)
	moves_made_label.text = str(value + 1).lpad(3, "0")
