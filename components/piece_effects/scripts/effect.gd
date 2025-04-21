class_name Effect extends Node2D

enum EffectType {
	ICE,
}

@export var health_component: HealthComponent
@export var effect_color: Color
@export var effect_color_rect: ColorRect
@export var type: EffectType

signal destroyed

func _ready() -> void:
	health_component.health_depleted.connect(_on_health_component_health_depleted)
	effect_color_rect.color = effect_color

func _on_health_component_health_depleted() -> void:
	destroyed.emit(self)
	queue_free()

func take_damage(amount: int) -> void:
	health_component.take_damage(amount)
