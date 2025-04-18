class_name IceEffect extends Node2D

@export var health_component: HealthComponent

func _ready() -> void:
	health_component.health_depleted.connect(_on_health_component_health_depleted)

func _on_health_component_health_depleted() -> void:
	queue_free()

func take_damage(amount: int) -> void:
	health_component.take_damage(amount)
