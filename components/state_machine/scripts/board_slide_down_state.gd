class_name BoardSlideDownState extends State

@export var board: Board
@export var slide_down_timer: Timer
@export var slided_down_pieces_next_state: State

var slide_down_timeout: bool = false

func _ready() -> void:
	slide_down_timer.timeout.connect(_on_slide_down_timer_timeout)

func enter() -> void:
	slide_down_timeout = false
	slide_down_timer.start()

func update(_delta) -> void:
	if not slide_down_timeout:
		return
		
	board._slide_pieces_down()
	finished.emit(slided_down_pieces_next_state.name)

func _on_slide_down_timer_timeout() -> void:
	slide_down_timeout = true
