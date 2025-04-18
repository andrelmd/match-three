class_name BoardStateMachine extends StateMachine

func _on_state_finished(target_state_name: String) -> void:
	print("changing from ", _current_state.name, " to ", target_state_name)
	super (target_state_name)
