class_name BoardRefillTimerState extends State

@export var board: Board
@export var refill_timer: Timer
@export var has_refilled_next_state: State

var refill_timeout: bool = false

func _ready() -> void:
	refill_timer.timeout.connect(_on_refill_timer_timeout)

func enter() -> void:
	refill_timeout = false
	refill_timer.start()

func update(_delta: float) -> void:
	if not refill_timeout:
		return
	
	board._refill_pieces()
	finished.emit(has_refilled_next_state.name)

func _on_refill_timer_timeout() -> void:
	refill_timeout = true
