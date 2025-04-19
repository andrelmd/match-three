@tool
class_name Piece extends Sprite2D

@export var piece_texture: Texture2D
@export var selected_piece_texture: Texture2D
@export var piece_type: String
@export var area_node: Area2D

var mouse_is_inside_area: bool = false
var is_selected: bool = false: set = _set_is_selected
var matched: bool = false: set = _set_matched

signal piece_selected(piece: Piece)
signal piece_deselected(piece: Piece)

func _set_matched(new_value: bool) -> void:
	matched = new_value
	modulate = Color(1, 1, 1, 0.5) if matched else Color(1, 1, 1, 1)

func _set_is_selected(new_value: bool) -> void:
	is_selected = new_value
	texture = selected_piece_texture if is_selected else piece_texture

func _ready():
	assert(piece_type != "", "Piece type must be set.")
	assert(area_node != null, "Area node must be set.")
	assert(piece_texture != null, "Piece texture must be set.")
	assert(selected_piece_texture != null, "Selected piece texture must be set.")
	
	texture = piece_texture
	area_node.mouse_entered.connect(_on_piece_mouse_entered)
	area_node.mouse_exited.connect(_on_piece_mouse_exited)

func _on_piece_mouse_entered():
	texture = selected_piece_texture
	mouse_is_inside_area = true

func _on_piece_mouse_exited():
	if !is_selected:
		texture = piece_texture

	mouse_is_inside_area = false

func move(target_position: Vector2):
	create_tween().tween_property(self, "position", target_position, 0.3).set_trans(Tween.TRANS_ELASTIC)

func destroy_matched():
	queue_free()
