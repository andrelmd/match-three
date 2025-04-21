class_name BoardCheckMatchState extends State

@export var board: Board
@export var no_match_next_state: State
@export var has_match_next_state: State

func enter() -> void:
	var matches := board.find_matches()
	for piece in matches:
		piece.matched = true
	if matches.size() > 0:
		finished.emit(has_match_next_state.name)
	else:
		finished.emit(no_match_next_state.name)
