class_name BoardInitializeState extends State

@export var board: Board
@export var board_initialized_next_state: State

func enter() -> void:
	board.initialize()

func update(_delta: float) -> void:
	finished.emit(board_initialized_next_state.name)
