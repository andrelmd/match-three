@tool
class_name Piece extends Sprite2D

@export var piece_texture: Texture2D
@export var selected_piece_texture: Texture2D
@export var piece_name: String
@export var selected: bool = false

@export var area_node: Area2D

signal piece_selected(piece: Piece)
signal piece_deselected(piece: Piece)

func _ready():
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
				texture = piece_texture
				piece_deselected.emit(self)
			else:
				selected = true
				texture = selected_piece_texture
				piece_selected.emit(self)
