@tool
class_name Piece extends Sprite2D

@export var piece_texture: Texture2D
@export var selected_piece_texture: Texture2D
@export var piece_type: String
@export var selected: bool = false : set = _set_selected

var matched: bool = false : set = _set_matched

func _set_matched(new_value: bool) -> void:
	matched = new_value
	modulate = Color(1, 1, 1, 0.5) if matched else Color(1, 1, 1, 1)

func _set_selected(new_value: bool) -> void:
	selected = new_value
	texture = selected_piece_texture if selected else piece_texture

@export var area_node: Area2D

signal piece_selected(piece: Piece)
signal piece_deselected(piece: Piece)

func _ready():
	assert(piece_type != "", "Piece type must be set.")
	texture = piece_texture
	area_node.mouse_entered.connect(_on_piece_mouse_entered)
	area_node.mouse_exited.connect(_on_piece_mouse_exited)
	area_node.input_event.connect(_on_piece_mouse_button_pressed)

func _on_piece_mouse_entered():
	texture = selected_piece_texture

func _on_piece_mouse_exited():
	if !selected:
		texture = piece_texture

func _on_piece_mouse_button_pressed(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected:
				selected = false
				piece_deselected.emit(self)
			else:
				selected = true
				piece_selected.emit(self)

func move(target_position: Vector2):
	create_tween().tween_property(self, "position", target_position, 0.3).set_trans(Tween.TRANS_ELASTIC)

func destroy_matched():
	queue_free()
