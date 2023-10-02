extends Node2D
class_name HealthComponent

@export var health: int = 100
var currentHealth: int = health

func Heal(amount: int):
	currentHealth = min(currentHealth + amount, health)


func TakeDamage(amount: int):
	currentHealth = max(currentHealth - amount, 0)

	if (currentHealth == 0):
		pass # TODO: Die!
