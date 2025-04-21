class_name BoardExecutePieceSkillsState extends State

@export var board: Board
@export var piece_holder: PieceHolder
@export var executed_skills_next_state: State

func enter() -> void:
	for width in board.max_width:
		for height in board.max_height:
			var cell_coordinate = Vector2i(width, height)
			var piece = piece_holder.get_in_coordinate(cell_coordinate)
			if piece == null:
				continue
			
			if not piece.matched:
				continue
			
			var skills = piece.skills.duplicate()
			for skill: SkillStrategy in skills:
				skill.execute(board, piece)
	
	finished.emit(executed_skills_next_state.name)
