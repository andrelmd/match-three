class_name StateMachine extends Node

@export var initial_state: State = null

@onready var _current_state: State = (func get_initial_state() -> State:
		return initial_state if initial_state != null else get_child(0)
).call()

func _unhandled_input(event: InputEvent) -> void:
	_current_state.handle_input(event)

func _process(delta: float) -> void:
	_current_state.update(delta)

func _physics_process(delta: float) -> void:
	_current_state.physics_update(delta)

func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_on_state_finished)
	await owner.ready
	_current_state.enter()

func _on_state_finished(target_state_name: String) -> void:
	var target_state: State = find_child(target_state_name)
	if target_state == null:
		return
	_current_state.exit()
	_current_state = target_state
	_current_state.enter()
