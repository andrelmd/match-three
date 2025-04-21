class_name Piece extends Node2D

@export var piece_sprite: Sprite2D
@export var piece_texture: Texture2D
@export var selected_piece_texture: Texture2D
@export var piece_type: String
@export var area_node: Area2D
@export var skills: Array[SkillStrategy]
@export var blink_component: BlinkComponent
@export var blink_duration_s: float = 0.2
@export var move_duration_s: float = 0.2

var mouse_is_inside_area: bool = false
var is_selected: bool = false: set = _set_is_selected
var matched: bool = false: set = _set_matched

signal piece_selected(piece: Piece)
signal piece_deselected(piece: Piece)
signal has_moved

func _set_matched(new_value: bool) -> void:
	matched = new_value
	modulate = Color(1, 1, 1, 0.5) if matched else Color(1, 1, 1, 1)

func _set_is_selected(new_value: bool) -> void:
	is_selected = new_value
	piece_sprite.texture = selected_piece_texture if is_selected else piece_texture

func _ready():
	assert(piece_type != "", "Piece type must be set.")
	assert(area_node != null, "Area node must be set.")
	assert(piece_texture != null, "Piece texture must be set.")
	assert(selected_piece_texture != null, "Selected piece texture must be set.")
	
	piece_sprite.texture = piece_texture
	area_node.mouse_entered.connect(_on_piece_mouse_entered)
	area_node.mouse_exited.connect(_on_piece_mouse_exited)
	
	for skill in find_children("*", "Skill"):
		skills.append(skill)

func _on_piece_mouse_entered():
	piece_sprite.texture = selected_piece_texture
	mouse_is_inside_area = true

func _on_piece_mouse_exited():
	if !is_selected:
		piece_sprite.texture = piece_texture

	mouse_is_inside_area = false

func move(target_position: Vector2):
	var tween = create_tween().tween_property(self, "position", target_position, move_duration_s).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	has_moved.emit()

func destroy_matched():
	await blink_component.blink(blink_duration_s)
	queue_free()
