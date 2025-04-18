class_name BoardDestroyMatchState extends State

@export var board: Board
@export var destroy_match_timer: Timer
@export var has_destroyed_next_state: State

var destroy_matchs_timeout: bool = false

func _ready() -> void:
	destroy_match_timer.timeout.connect(_on_destroy_match_timer_timeout)

func enter() -> void:
	destroy_matchs_timeout = false
	destroy_match_timer.start()

func update(_delta) -> void:
	if not destroy_matchs_timeout:
		return
	
	board._destroy_matched()
	finished.emit(has_destroyed_next_state.name)

func _on_destroy_match_timer_timeout() -> void:
	destroy_matchs_timeout = true
