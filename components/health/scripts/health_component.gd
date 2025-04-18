class_name HealthComponent extends Node

@export var max_health: int
var current_health: int: set = _set_current_health


signal healed(quantity: int)
signal damaged(quantity: int)
signal health_depleted


func _ready() -> void:
	current_health = max_health


func _set_current_health(new_health: int) -> int:
	var new_value = clampi(new_health, 0, max_health)
	
	if new_value == 0:
		health_depleted.emit()
	
	return new_value


func take_damage(amount: int):
	current_health -= amount
	damaged.emit(amount)


func heal(amount: int):
	current_health += amount
	healed.emit(amount)
