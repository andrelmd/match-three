class_name BoardCheckMatchState extends State

@export var board: Board
@export var no_match_next_state: State
@export var has_match_next_state: State

var has_match: bool = false

func enter() -> void:
	has_match = board._find_and_set_matchs()

func update(_delta: float) -> void:
	if has_match:
		finished.emit(has_match_next_state.name)
	else:
		finished.emit(no_match_next_state.name)
